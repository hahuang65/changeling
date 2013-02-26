module Changeling
  module Async
    class ResqueWorker
      @queue = :changeling

      def self.perform(json)
        Changeling::Models::Logling.create(JSON.parse(json))
      end
    end
  end
end
