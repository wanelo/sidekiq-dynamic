# Sidekiq::Dynamic

Sidekiq::Dynamic allows Sidekiq jobs to choose their queue or shard/pool based on the job's arguments.

## Installation

```ruby
# Gemfile
gem 'sidekiq-dynamic'
```

## Usage

If you have a lot of Sidekiq queues and/or jobs, chances are good that you will eventually overrun the ability of a single Redis instance. When that happens, you need to be able to shard your jobs across multiple Redis instances easily. Let's say you have two Redis instances, and you want to send Sidekiq jobs to both of them.

```
# List shards somewhere (you could even use Sidekiq.config)
shards = {
  :cache => "127.0.0.1:5901",
  :images => "127.0.0.1:5902"
}
```

Using a regular Sidekiq::Worker, it's pretty easy to assign particular jobs to a particular queue or shard.

```
# Assign a worker a static queue, and/or a static shard
require "sidekiq/worker"

class StaticSidekiqWorker
  include Sidekiq::Worker
  sidekiq_options queue: "cache_regenerator", pool: shards[:cache]
end
```

In contrast to vanilla Sidekiq workers, Sidekiq::Dynamic workers allow you to examine the job arguments and choose a queue or shard for the job to be sent to when the job is queued.

```
# Dynamic jobs use the job arguments to determine queue or shard
require "sidekiq/dynamic/worker"

class DynamicShardAndQueueWorker
  include Sidekiq::Dynamic::Worker

  # In this example, every shard will have both queues.
  dynamic_queue do |args|
    rand(1).zero? ? "cache_sweeper" : "image_generator"
  end

  dynamic_shard do |args|
    case args.first
    when "hard_work", "other_hard_work"
      shards[:cache]
    else
      shards[:images]
    end
  end

end
```

Keep in mind that neither this gem nor Sidekiq itself helps with running Sidekiq workers on each shard and queue. You'll need to start separate Sidekiq processes that are configured to talk to each Redis shard, and you'll need to list the queues those processes should work from.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sidekiq-dynamic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
