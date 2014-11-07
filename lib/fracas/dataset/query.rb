module Fracas
  class Dataset
    module Query
      def to_query
        {
          index: indices.join(','),
          type: types.join(','),
          body: {
            query: queries,
            filter: filters
          }
        }
      end

      def indices
        if (indices = @query[:indices]).empty?
          ['_all']
        else
          indices
        end
      end

      def types
        @query[:types]
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
