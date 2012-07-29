module Changeling
  module Models
    class Logling
      attr_accessor :klass, :object_id, :modifications, :before, :after, :changed_at

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


        def redis_key(klass, object_id)
          "changeling::#{klass}::#{object_id}"
        end

        def where(args)
          # args = {
          #   :klass => object.class.to_s.underscore.pluralize,
          #   :object_id => object.id.to_s
          # }

          return [] unless args[:klass] && args[:object_id]

          key = self.redis_key(args[:klass], args[:object_id])
          length = Changeling.redis.llen(key)
          Changeling.redis.lrange(key, 0, length)
        end
      end

      def as_json
        {
          :modifications => self.modifications,
          :changed_at => self.changed_at
        }
      end

      def initialize(object, changes)
        self.klass = object.class.to_s.underscore.pluralize
        self.object_id = object.id.to_s
        self.modifications = changes

        self.before, self.after = Logling.parse_changes(changes)

        self.changed_at = object.updated_at
      end

      def redis_key
        Logling.redis_key(self.klass, self.object_id)
      end

      def save
        key = self.redis_key
        value = self.serialize

        Changeling.redis.lpush(key, value)
      end

      def serialize
        self.as_json.to_json
      end
    end
  end
end
