module Pariah
  class Dataset
    module Query
      def to_query
        body = {
          query: {
            match_all: {}
          }
        }

        if filter = @query[:filter]
          body[:filter] = filter.to_query
        end

        if sort = @query[:sort]
          body[:sort] = sort
        end

        if size = @query[:size]
          body[:size] = size
        end

        if from = @query[:from]
          body[:from] = from
        end

        {
          index: indices_as_string,
          type: types_as_string,
          body: body
        }
      end

      private

      def single_index
        indices = @query[:indices]
        raise "Need exactly one index; have #{indices.inspect}" unless indices.count == 1
        indices.first
      end

      def single_type
        types = @query[:types]
        raise "Need exactly one type; have #{types.inspect}" unless types.count == 1
        types.first
      end

      def indices_as_string
        if (indices = @query[:indices]).empty?
          '_all'
        else
          indices.join(',')
        end
      end

      def types_as_string
        @query[:types].join(',')
      end
    end
  end
end
