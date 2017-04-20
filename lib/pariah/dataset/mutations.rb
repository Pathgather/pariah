# frozen_string_literal: true

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

      def bool(**args)
        merge_filter(Bool.new(args))
      end

      def filter(*args)
        merge_filter(Bool.new(must: args))
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

      def exclude_source(setting = true)
        merge_replace(exclude_source: setting)
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

      def with_extend(&block)
        clone.tap { |c| c.extend(Module.new(&block)) }
      end

      def query
        current_query = @opts[:query] || {match_all: {}}
        merge_replace(query: yield(current_query))
      end

      def include_explanation
        merge_replace(explain: true)
      end

      protected

      def merge_filter(filter)
        new_filter =
          case current_filter = @opts[:filter]
          when Bool
            if current_filter.can_merge?(filter)
              current_filter.merge(filter)
            else
              Bool.new(must: [current_filter, filter])
            end
          when NilClass
            filter
          else
            raise Error, "Unsupported filter option: #{current_filter.class}"
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
