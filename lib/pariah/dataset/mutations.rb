module Pariah
  class Dataset
    module Mutations
      def from_indices(*indices)
        merge(indices: indices)
      end
      alias :from_index :from_indices

      def from_types(*types)
        merge(types: types)
      end
      alias :from_type :from_types

      def filter(condition = {})
        merge filters: condition
      end

      def merge(query)
        clone.tap { |clone| clone.merge!(query) }
      end

      def merge!(query)
        @query = @query.merge(query) do |key, oldval, newval|
          case key
          when :indices, :types then oldval + newval
          when :filters         then oldval + [newval]
          else raise "Unrecognized key! #{key.inspect}"
          end
        end
      end
    end
  end
end
