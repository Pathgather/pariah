# frozen_string_literal: true

require 'pariah/dataset/filters/and'
require 'pariah/dataset/filters/term'

module Pariah
  class Dataset
    module Mutations
      def [](*indices)
        merge_replace(indices: indices.flatten)
      end

      def append_indices(*indices)
        merge_append(indices: indices.flatten)
      end
      alias :append_index   :append_indices
      alias :append_indexes :append_indices

      def types(*types)
        merge_replace(types: types.flatten)
      end
      alias :type :types

      def append_types(*types)
        merge_append(types: types.flatten)
      end
      alias :append_type :append_types

      def term(condition = {})
        append_filters condition.map { |k, v| Filters::Term.new(k => v) }
      end

      def unfiltered
        merge_replace(filter: nil)
      end

      def sort(*args)
        merge_replace(sort: args.flatten)
      end

      def size(size)
        merge_replace(size: size)
      end

      def from(from)
        merge_replace(from: from)
      end

      def aggregates(*aggregates)
        merge_replace(aggregates: aggregates)
      end

      def fields(*fields)
        merge_replace(include_fields: fields)
      end

      def append_fields(*fields)
        merge_append(include_fields: fields)
      end

      def exclude_fields(*fields)
        merge_replace(exclude_fields: fields)
      end

      def set_index_schema(schema)
        merge_replace(index_schema: schema)
      end

      protected

      def append_filters(filters)
        new_filter =
          case current_filter = @opts[:filter]
          when Filters::And
            Filters::And.new(*current_filter.args, *filters)
          when NilClass
            filters.length > 1 ? Filters::And.new(*filters) : filters.first
          else
            Filters::And.new(current_filter, *filters)
          end

        merge_replace filter: new_filter
      end

      def merge_replace(opts)
        clone.tap { |clone| clone.merge_replace!(opts) }
      end

      def merge_append(opts)
        clone.tap { |clone| clone.merge_append!(opts) }
      end

      def merge_replace!(opts)
        @opts = @opts.merge(opts)
      end

      def merge_append!(opts)
        @opts = @opts.merge(opts) do |key, oldval, newval|
          oldval + Array(newval)
        end
      end
    end
  end
end
