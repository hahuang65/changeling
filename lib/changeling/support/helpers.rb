module Changeling
  module Support
    module Helpers
      def list_changes(object, count = 10)
        return [] unless object
        loglings = Changeling::Models::Logling.records_for(object, count)

        render :partial => "changeling/list_changes", :locals => { :loglings => loglings }
      end
    end
  end
end
