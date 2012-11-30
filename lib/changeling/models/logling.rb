module Changeling
  module Models
    class Logling
      extend ActiveModel::Naming
      attr_accessor :klass, :oid, :modifications, :before, :after, :modified_at

      include Tire::Model::Search
      include Tire::Model::Persistence

      property :klass, :type => 'string'
      property :oid, :type => 'string'
      property :modifications, :type => 'string'
      property :modified_at, :type => 'date'

      mapping do
        indexes :klass, :type => "string"
        indexes :oid, :type => "string"
        indexes :modifications, :type => 'string'
        indexes :modified_at, :type => 'date'
      end

      class << self
        def create(object)
          logling = self.new(object)
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
          object.class
        end

        def records_for(object, length = nil)
          self.tire.index.refresh
          results = self.search do
           query do
             filtered do
               query { all }
               filter :terms, :klass => [Logling.klassify(object).to_s.underscore]
               filter :terms, :oid => [object.id.to_s]
             end
           end

           sort { by :modified_at, "desc" }
          end.results

          if length
            results.take(length)
          else
            results
          end
        end
      end

      def to_indexed_json
        {
          :klass => self.klass.to_s.underscore,
          :oid => self.oid.to_s,
          :modifications => self.modifications.to_json,
          :modified_at => self.modified_at
        }.to_json
      end

      def as_json
        {
          :class => self.klass,
          :oid => self.oid,
          :modifications => self.modifications,
          :modified_at => self.modified_at
        }
      end

      def initialize(object)
        if object.class == Hash
          changes = JSON.parse(object['modifications'])
          self.klass = object['klass'].camelize.constantize
          self.oid = object['oid'].to_i.to_s == object['oid'] ? object['oid'].to_i : object['oid']
          self.modifications = changes

          self.before, self.after = Logling.parse_changes(changes)

          self.modified_at = DateTime.parse(object['modified_at'])
        else
          changes = object.changes

          # Remove updated_at field.
          changes.delete("updated_at")

          self.klass = Logling.klassify(object)
          self.oid = object.id
          self.modifications = changes

          self.before, self.after = Logling.parse_changes(changes)

          if object.respond_to?(:updated_at)
            self.modified_at = object.updated_at
          else
            self.modified_at = Time.now
          end
        end
      end

      def save
        _run_save_callbacks {}
      end
    end
  end
end
