module Changeling
  module Trackling
    def self.included(base)
      base.after_save :save_logling
    end

    def save_logling
      if changes = self.previous_changes
        logling = Changeling::Models::Logling.new(changes)
      end
    end
  end
end
