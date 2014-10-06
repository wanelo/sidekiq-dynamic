# Sidekiq::Dynamic

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-dynamic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-dynamic

## Usage

```
# Add shards to Sidekiq configuration hash
Sidekiq.configure do |sidekiq|
  sidekiq.options[:shards] = {
    :cache => "127.0.0.1:5901",
    :images => "127.0.0.1:5902"
  }
end

# Each job has a static queue, each queue has a static shard
require "sidekiq/worker"

class StaticSidekiqWorker
  include Sidekiq::Worker
  sidekiq_options queue: "cache_regenerator", pool: Sidekiq.options[:shards][:cache]
end

# Dynamic jobs use the job arguments to determine queue or shard
# In this example, every shard will have both queues.
require "sidekiq/dynamic/worker"

class DynamicShardAndQueueWorker
  include Sidekiq::Dynamic::Worker

  dynamic_queue do |args|
    rand(1).zero? ? "cache_sweeper" : "image_generator"
  end
  
  dynamic_shard do |args|
    case args.first
    when "hard_work", "other_hard_work"
      Sidekiq.options[:shards][:cache]
    else
      Sidekiq.options[:shards][:images]
    end
  end

end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sidekiq-dynamic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
