require "sidekiq/dynamic/worker"
# hay guise sidekiq/worker depends on Sidekiq but doesn't require it
require "sidekiq"

RSpec.describe Sidekiq::Dynamic::Worker do
  let(:worker) {
    Class.new do
      include Sidekiq::Dynamic::Worker
      class_attribute :class_redis_pool
    end
  }

  let(:redis) { double("redis", sadd: true).tap { |redis|
    allow(redis).to receive(:with).and_yield(redis)
    allow(redis).to receive(:multi).and_yield.and_return([])
  }}

  let(:other_redis) { double("other_redis", sadd: true).tap { |redis|
    allow(redis).to receive(:with).and_yield(redis)
    allow(redis).to receive(:multi).and_yield.and_return([])
  }}

  before do
    Sidekiq.instance_variable_set(:@redis, redis)
  end
  
  it "can instantiate a Sidekiq::Dynamic::Worker" do
    expect(worker.new).to be_kind_of(Sidekiq::Dynamic::Worker)
  end
  
  it "can still enqueue a job" do
    expect(redis).to receive(:lpush).once.with('queue:default', instance_of(Array))
    worker.perform_async("omg")
  end
  
  it "can still enqueue a job to a static queue" do
    worker.class_eval { sidekiq_options queue: 'amazing' }
    
    expect(redis).to receive(:lpush).once.with('queue:amazing', instance_of(Array))
    worker.perform_async("omg")
  end
  
  it "can enqueue a job to a dynamic queue" do
    worker.class_eval do
      dynamic_queue { |args| args.first }
    end
    
    expect(redis).to receive(:lpush).once.with('queue:omg', instance_of(Array))
    worker.perform_async("omg")
  end
  
  it "can still enqueue a job to a static shard" do
    worker.class_redis_pool = other_redis
    worker.class_eval { sidekiq_options pool: class_redis_pool }

    expect(other_redis).to receive(:lpush).once.with('queue:default', instance_of(Array))
    worker.perform_async("omg")
  end
  
  it "can enqueue a job to a dynamic shard" do
    worker.class_redis_pool = other_redis
    worker.class_eval do
      dynamic_shard { |args| class_redis_pool }
    end
    
    expect(other_redis).to receive(:lpush).once.with('queue:default', instance_of(Array))
    worker.perform_async("omg")
  end

  it "can ignores the dynamic shard during `Sidekiq::Client.via`" do
    worker.class_redis_pool = other_redis
    worker.class_eval do
      dynamic_shard { |args| class_redis_pool }
    end
    
    expect(redis).to receive(:lpush).once.with('queue:default', instance_of(Array))
    Sidekiq::Client.via(redis) do
      worker.perform_async("omg")
    end
  end

end