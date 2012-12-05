module Changeling
  module Trackling
    def self.included(base)
      base.after_update :save_logling
    end

    def save_logling
      if self.changes && !self.changes.empty?
        logling = Changeling::Models::Logling.create(self)
      end
    end
  end
end
