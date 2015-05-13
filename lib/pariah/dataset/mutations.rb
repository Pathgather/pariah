module Pariah
  class Dataset
    module Mutations
      def from_indices(*indices)
        merge_replace(indices: indices.flatten)
      end
      alias :from_index :from_indices

      def append_indices(*indices)
        merge_append(indices: indices.flatten)
      end
      alias :append_index :append_indices

      def from_types(*types)
        merge_replace(types: types.flatten)
      end
      alias :from_type :from_types

      def append_types(*types)
        merge_append(types: types.flatten)
      end
      alias :append_type :append_types

      def filter(condition = {})
        merge_append(filters: condition)
      end

      def unfiltered
        merge_replace(filters: [])
      end

      def sort(*args)
        merge_replace(sort: args.flatten)
      end

      protected

      def merge_replace(query)
        clone.tap { |clone| clone.merge_replace!(query) }
      end

      def merge_append(query)
        clone.tap { |clone| clone.merge_append!(query) }
      end

      def merge_replace!(query)
        @query = @query.merge(query)
      end

      def merge_append!(query)
        @query = @query.merge(query) do |key, oldval, newval|
          newval = [newval] unless newval.is_a?(Array)
          oldval + newval
        end
      end
    end
  end
end
