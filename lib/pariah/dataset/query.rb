# frozen_string_literal: true

module Pariah
  class Dataset
    module Query
      def to_query
        bool_query = {
          must: (@opts[:query] || {match_all: {}})
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

        if explain = @opts[:explain]
          body[:explain] = explain
        end

        if search_after = @opts[:search_after]
          body[:search_after] = search_after
        end

        if post_filter = @opts[:post_filter]
          body[:post_filter] = post_filter
        end

        source_option =
          if @opts[:exclude_source]
            false
          elsif (include_fields = @opts[:include_fields]) ||
                (exclude_fields = @opts[:exclude_fields])

            o = {}
            o[:includes] = include_fields if include_fields
            o[:excludes] = exclude_fields if exclude_fields
            o
          end

        body[:_source] = source_option unless source_option.nil?

        if aggs = @opts[:aggs]
          body[:aggs] = aggs.first
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
