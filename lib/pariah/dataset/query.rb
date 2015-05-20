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

        include_fields = @query[:include_fields]
        exclude_fields = @query[:exclude_fields]

        if (include_fields && include_fields.any?) || (exclude_fields && exclude_fields.any?)
          source = {}

          if include_fields && include_fields.any?
            source[:include] = include_fields
          end

          if exclude_fields && exclude_fields.any?
            source[:exclude] = exclude_fields
          end

          body[:_source] = source
        end

        if (aggregates = @query[:aggregates]) && aggregates.any?
          hash = {}
          aggregates.each { |field| hash[field] = { terms: { field: field } } }
          body[:aggs] = hash
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
