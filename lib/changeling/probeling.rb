module Changeling
  module Probeling
    def all_loglings
      Changeling::Models::Logling.records_for(self)
    end
    alias_method :all_history, :all_loglings

    def loglings(records = 10)
      Changeling::Models::Logling.records_for(self, records.to_i)
    end
    alias_method :history, :loglings

    def loglings_for_field(field_name, records = nil)
      Changeling::Models::Logling.records_for(self, records ? records.to_i : nil, field_name.to_s)
    end
    alias_method :history_for_field, :loglings_for_field
  end
end
