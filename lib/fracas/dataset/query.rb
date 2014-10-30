module Fracas
  class Dataset
    module Query
      def to_query
        query = {
          index: indices.join(','),
          type: types.join(','),
          body: {
            query: queries,
            filter: filters
          }
        }
      end

      def indices
        indices = @query[:indices]
        if indices.count.zero?
          ['_all']
        else
          indices
        end
      end

      def types
        types = @query[:types]
        if types.count.zero?
          []
        else
          types
        end
      end

      def queries
        {
          match_all: {}
        }
      end

      def filters
        filters = @query[:filters]
        if filters.count.zero?
          {
            match_all: {}
          }
        else
          {
            and: filters.map { |w|
              {
                term: w
              }
            }
          }
        end
      end
    end
  end
end
