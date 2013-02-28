module Changeling
  module Support
    class Search
      def self.find_by(args)
        return [] unless args.kind_of?(Hash)

        filters = args[:filters]
        sort = args[:sort]
        return [] unless filters || sort

        size = args[:size] || 10

        @class = Changeling::Models::Logling
        @class.tire.index.refresh

        results = @class.search :per_page => size do
          query do
            filtered do
              query { all }
              filters.each do |f|
                filter :terms, { f.first[0].to_sym => [f.first[1].to_s] }
              end
            end
          end

          sort { by sort[:field], sort[:direction].to_s }
        end.results

        # Some apps may return Tire::Results::Item objects in results instead of Changeling objects.
        results.map { |result|
          if result.class == @class
            result
          elsif result.class == Tire::Results::Item
            @class.new(JSON.parse(result.to_json))
          elsif result.class == Hash
            @class.new(result)
          end
        }
      end
    end
  end
end
