module Changeling
  module Probeling
    def all_history
      Changeling::Models::Logling.records_for(self)
    end

    def history(records = 10)
      Changeling::Models::Logling.records_for(self, records.to_i)
    end

    def history_for_field(field_name, records = nil)
      Changeling::Models::Logling.records_for(self, records ? records.to_i : nil, field_name.to_s)
    end
  end
end
