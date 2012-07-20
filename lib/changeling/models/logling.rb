module Changeling
  module Models
    class Logling
      class << self
        def create(object, changes)
          logling = self.new(object, changes)
          logling.save
        end
      end

      def save

      end
    end
  end
end
