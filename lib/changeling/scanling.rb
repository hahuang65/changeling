module Changeling
  module Scanling
    def all_loglings
      Changeling::Models::Logling.records_for(self)
    end
  end
end
