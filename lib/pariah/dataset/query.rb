# frozen_string_literal: true

module Pariah
  class Dataset
    module Query
      def to_query
        bool_query = {
          must: {
            match_all: {}
          }
        }

        if filter = @query[:filter]
          bool_query[:filter] = filter.to_query
        end

        body = {
          query: {
            bool: bool_query
          }
        }

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

        if include_fields || exclude_fields
          source = {}

          if include_fields
            source[:include] = include_fields
          end

          if exclude_fields
            source[:exclude] = exclude_fields
          end

          body[:_source] = source
        end

        if aggregates = @query[:aggregates]
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
        unless indices && indices.count == 1
          raise "Need exactly one index; have #{indices.inspect}"
        end
        indices.first
      end

      def single_type
        types = @query[:types]
        unless types && types.count == 1
          raise "Need exactly one type; have #{types.inspect}"
        end
        types.first
      end

      def indices_as_string
        if indices = @query[:indices]
          indices.join(',')
        else
          :_all
        end
      end

      def types_as_string
        types = @query[:types]
        types ? types.join(',') : ''
      end
    end
  end
end
