module Changeling
  module Async
    module Trackling
      def self.included(base)
        base.after_update :async_save_logling
      end

      def async_save_logling
        unless defined?(Sidekiq) || defined?(Resque)
          raise Changeling::Exceptions::AsyncGemRequired
        end

        if self.changes && !self.changes.empty?
          logling = Changeling::Models::Logling.new(self)

          if defined?(Sidekiq)
            Changeling::Async::SidekiqWorker.perform_async(logling.to_indexed_json)
          elsif defined?(Resque)
            Resque.enqueue(Changeling::Async::ResqueWorker, logling.to_indexed_json)
          end
        end

        true
      end
    end
  end
end
