module Changeling
  module Exceptions
    class AsyncGemRequired < StandardError
      def to_s
        "Changeling's asynchronous features require either the Sidekiq (https://github.com/mperham/sidekiq) or Resque (https://github.com/defunkt/resque) background job processing gems. Please install either one and try again."
      end
    end
  end
end
