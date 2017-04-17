# frozen_string_literal: true

module Pariah
  class Dataset
    module Actions
      def refresh
        execute_request(
          method: :post,
          path: [indices_as_string, '_refresh'],
        )
      end

      def create_index
        unless schema = @opts[:index_schema]
          raise Error, "No index_schema specified!"
        end

        # Ensure that dynamic field mapping is explicitly disallowed.
        settings = schema[:settings] ||= {}
        settings['index.mapper.dynamic'] = false

        execute_request(
          method: :put,
          path: single_index,
          body: schema,
          allowed_codes: [200, 400], # Index may already exist.
        )
      end

      def drop_index
        execute_request(
          method: :delete,
          path: indices_as_string,
        )
      end

      def each(&block)
        with_loaded_results { |ds| ds.all.each(&block) }
      end

      def all
        with_loaded_results do |ds|
          ds.results[:hits][:hits].map do |hit|
            hit[:fields] || hit[:_source]
          end
        end
      end

      def aggregate_results
        with_loaded_results { |ds| ds.results[:aggregations] }
      end

      def count
        with_loaded_results { |ds| ds.results[:hits][:total] }
      end

      def load
        clone.tap(&:load!)
      end

      def upsert(records)
        unless records.is_a?(Array)
          records = [records]
        end

        records = records.compact
        return if records.empty?

        current_type = nil
        rows = []

        records.each do |record|
          metadata = {}

          if id = record[:id]
            metadata[:_id] = id
          end

          if parent = record[:parent]
            metadata[:parent] = parent
          end

          if i = record.delete(:index)
            metadata[:_index] = i
          end

          if t = record.delete(:type)
            metadata[:_type] = t
          elsif i
            # We're sending the record to a different index, so we need to
            # make sure we specify the type.
            current_type ||= single_type
            metadata[:_type] = current_type
          end

          rows << JSON.dump(index: metadata)
          rows << JSON.dump(record)
        end

        body = rows.join("\n") << "\n"

        execute_request(
          method: :post,
          path: [single_index, single_type, '_bulk'],
          body: body,
        )
      end

      protected

      def load!
        @results =
          execute_request(
            method: :post,
            path: [indices_as_string, types_as_string, '_search'],
            body: to_query,
          )
      end

      private

      def with_loaded_results
        yield(results ? self : load)
      end
    end
  end
end
