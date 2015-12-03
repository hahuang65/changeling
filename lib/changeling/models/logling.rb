module Changeling
  module Models
    class Logling
      extend ActiveModel::Naming
      attr_accessor :klass, :oid, :modified_by, :modifications, :before, :after, :modified_at, :modified_fields

      include Tire::Model::Search
      include Tire::Model::Callbacks
      include Tire::Model::Persistence

      property :klass, :type => 'string'
      property :oid, :type => 'string'
      property :modified_by, :type => 'string'
      property :modifications, :type => 'string'
      property :modified_fields, :type => 'string', :analyzer => 'keyword'
      property :modified_at, :type => 'date'

      mapping do
        indexes :klass, :type => 'string'
        indexes :oid, :type => 'string'
        indexes :modified_by, :type => 'string'
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
          object.class.to_s.underscore
        end

        def records_for(object, length = nil, field = nil)
          filters = [
            { :klass => Logling.klassify(object).split('/') },
            { :oid => object.id.to_s }
          ]

          filters << { :modified_fields => field } if field

          sort = {
            :field => :modified_at,
            :direction => :desc
          }

          results = Changeling::Support::Search.find_by(:filters => filters, :sort => sort, :size => length)
        end
      end

      def to_indexed_json
        {
          :id => self.id,
          :klass => self.klass.to_s.underscore,
          :oid => self.oid.to_s,
          :modified_by => self.modified_by,
          :modifications => self.modifications.to_json,
          :modified_at => self.modified_at,
          :modified_fields => self.modified_fields
        }.to_json
      end

      def as_json
        {
          :class => self.klass,
          :oid => self.oid,
          :modified_by => self.modified_by,
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
          self.modified_by = object['modified_by'].to_i.to_s == object['modified_by'] ? object['modified_by'].to_i : object['modified_by']
          self.modifications = changes
          self.modified_fields = self.modifications.keys

          self.before, self.after = Logling.parse_changes(changes)

          self.modified_at = DateTime.parse(object['modified_at'])
        else
          changes = object.changes.reject { |k, v| v.nil? }
          # Remove updated_at field.
          changes.delete("updated_at")

          self.klass = object.class
          self.oid = object.id
          self.modified_by = Changeling.blame_user.try(:id) || nil
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
          self.update_index
        end
      end
    end
  end
end
