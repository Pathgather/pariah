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

        if filter = @opts[:filter]
          bool_query[:filter] = filter
        end

        body = {
          query: {
            bool: bool_query
          }
        }

        if sort = @opts[:sort]
          body[:sort] = sort
        end

        if size = @opts[:size]
          body[:size] = size
        end

        if from = @opts[:from]
          body[:from] = from
        end

        include_fields = @opts[:include_fields]
        exclude_fields = @opts[:exclude_fields]

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

        if aggregates = @opts[:aggregates]
          hash = {}
          aggregates.each { |field| hash[field] = { terms: { field: field } } }
          body[:aggs] = hash
        end

        body
      end

      private

      def resolve_indices
        if indices = @opts[:indices]
          indices.flat_map do |index|
            if index.respond_to?(:call)
              index.call
            else
              index
            end
          end
        end
      end

      def single_index
        indices = resolve_indices
        unless indices && indices.count == 1
          raise "Need exactly one index; have #{indices.inspect}"
        end
        indices.first.to_s
      end

      def single_type
        types = @opts[:types]
        unless types && types.count == 1
          raise "Need exactly one type; have #{types.inspect}"
        end
        types.first
      end

      def indices_as_string
        if indices = resolve_indices
          indices.join(',')
        else
          :_all
        end
      end

      def types_as_string
        types = @opts[:types]
        types ? types.join(',') : ''
      end
    end
  end
end
