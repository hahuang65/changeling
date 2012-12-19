module Changeling
  module Models
    class Logling
      extend ActiveModel::Naming
      attr_accessor :klass, :oid, :modifications, :before, :after, :modified_at, :modified_fields

      include Tire::Model::Search
      include Tire::Model::Persistence

      property :klass, :type => 'string'
      property :oid, :type => 'string'
      property :modifications, :type => 'string'
      property :modified_fields, :type => 'string', :analyzer => 'keyword'
      property :modified_at, :type => 'date'

      mapping do
        indexes :klass, :type => "string"
        indexes :oid, :type => "string"
        indexes :modifications, :type => 'string'
        indexes :modified_fields, :type => 'string', :analyzer => 'keyword'
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

        # TODO: Refactor me! More specs!
        def records_for(object, length = nil, field = nil)
          self.tire.index.refresh

          if field
            results = self.search do
             query do
               filtered do
                 query { all }
                 filter :terms, :klass => [Logling.klassify(object).to_s.underscore]
                 filter :terms, :oid => [object.id.to_s]
                 filter :terms, :modified_fields => [field]
               end
             end

             sort { by :modified_at, "desc" }
            end.results
          else
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
          end

          results = results.take(length) if length

          # Some apps may return Tire::Results::Item objects in results instead of Changeling objects.
          results.map { |result|
            if result.class == Changeling::Models::Logling
              result
            elsif result.class == Tire::Results::Item
              Logling.new(JSON.parse(result.to_json))
            elsif result.class == Hash
              Logling.new(result)
            end
          }
        end
      end

      def to_indexed_json
        {
          :id => self.id,
          :klass => self.klass.to_s.underscore,
          :oid => self.oid.to_s,
          :modifications => self.modifications.to_json,
          :modified_at => self.modified_at,
          :modified_fields => self.modified_fields
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

      def id
        # Make sure ElasticSearch creates new entries rather than update old entries.
        Digest::MD5.hexdigest("#{self.klass}:#{self.oid}:#{self.modifications}")
      end

      def initialize(object)
        if object.class == Hash
          changes = JSON.parse(object['modifications'])
          self.klass = object['klass'].camelize.constantize
          self.oid = object['oid'].to_i.to_s == object['oid'] ? object['oid'].to_i : object['oid']
          self.modifications = changes
          self.modified_fields = self.modifications.keys

          self.before, self.after = Logling.parse_changes(changes)

          self.modified_at = DateTime.parse(object['modified_at'])
        else
          changes = object.changes.reject { |k, v| v.nil? }
          # Remove updated_at field.
          changes.delete("updated_at")

          self.klass = Logling.klassify(object)
          self.oid = object.id
          self.modifications = changes
          self.modified_fields = self.modifications.keys

          self.before, self.after = Logling.parse_changes(changes)

          if object.respond_to?(:updated_at)
            self.modified_at = object.updated_at
          else
            self.modified_at = Time.now
          end
        end
      end

      def save
        unless self.modifications.empty?
          _run_save_callbacks {}
        end
      end
    end
  end
end
