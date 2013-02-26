module Changeling
  module Async
    class SidekiqWorker
      # If Sidekiq is not installed, we'll throw an error when trying to access Changeling::Async::Trackling
      begin
        include Sidekiq::Worker
        sidekiq_options :queue => :changeling
      rescue
      end

      def perform(json)
        Changeling::Models::Logling.create(JSON.parse(json))
      end
    end
  end
end
