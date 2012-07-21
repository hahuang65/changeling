module Changeling
  module Models
    class Logling
      attr_accessor :klass, :object_id, :before, :after

      class << self
        def create(object, changes)
          logling = self.new(object, changes)
          logling.save
        end

        def parse_changes(changes)
          before = {}
          after = {}

          changes.each_pair do |attr, values|
            before[attr] = values[0]
            after[attr] = values[1]
          end

          [before, after]
        end
      end

      def initialize(object, changes)
        self.klass = object.class.to_s.underscore.pluralize
        self.object_id = object.id.to_s

        self.before, self.after = Logling.parse_changes(changes)
      end

      def save
      end
    end
  end
end
