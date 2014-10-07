require "sidekiq/worker"

module Sidekiq
  module Dynamic
    module Worker

      def self.included(base)
        base.send(:include, Sidekiq::Worker)
        base.class_attribute :dynamic_shard_proc
        base.class_attribute :dynamic_queue_proc
        base.extend(ClassMethods)
      end
  
      module ClassMethods
        def dynamic_shard(&block)
          self.dynamic_shard_proc = block
        end
  
        def dynamic_queue(&block)
          self.dynamic_queue_proc = block
        end

        def client_push(item) # :nodoc:
          old_pool = Thread.current[:sidekiq_via_pool]
          item['queue'] = dynamic_queue_proc.call(item['args']) if dynamic_queue_proc
          Thread.current[:sidekiq_via_pool] ||= dynamic_shard_proc.call(item['args']) if dynamic_shard_proc
          super(item)
        ensure
          Thread.current[:sidekiq_via_pool] = old_pool
        end
      end
  
    end
  end
end
