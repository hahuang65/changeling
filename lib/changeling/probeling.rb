module Changeling
  module Probeling
    def loglings(records = 10)
      Changeling::Models::Logling.records_for(self, records.to_i)
    end
    alias_method :history, :loglings

    def loglings_for_field(field_name, records = 10)
      Changeling::Models::Logling.records_for(self, records.to_i, field_name.to_s)
    end
    alias_method :history_for_field, :loglings_for_field
  end
end
