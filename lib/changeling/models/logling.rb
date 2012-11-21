module Changeling
  module Models
    class Logling
      include Tire::Model::Search
      attr_accessor :klass, :oid, :modifications, :before, :after, :changed_at

      # For Tire to name the index
      index_name 'Loglings'

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

        def klassify(object)
          object.class.to_s.underscore
        end

        def records_for(object)
          klass = self.klassify(object)
          id = self.id.to_s

          results = self.tire.search do
            query do

            end

            sort { by :changed_at, 'desc' }
          end

          results.map { |value| self.new(object, JSON.parse(value)['modifications']) }
        end
      end

      def to_indexed_json
        {
          :klass => self.klass,
          :oid => self.oid,
          :modifications => self.modifications,
          :changed_at => self.changed_at
        }
      end

      def initialize(object, changes)
        # Remove updated_at field.
        changes.delete("updated_at")

        self.klass = Logling.klassify(object)
        self.oid = object.id.to_s
        self.modifications = changes

        self.before, self.after = Logling.parse_changes(changes)

        if object.respond_to?(:updated_at)
          self.changed_at = object.updated_at
        else
          self.changed_at = Time.now
        end
      end

      def save
        self.update_elastic_search_index
      end
    end
  end
end
