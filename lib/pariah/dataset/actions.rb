# frozen_string_literal: true

module Pariah
  class Dataset
    module Actions
      def refresh
        synchronize do |conn|
          conn.post path: [indices_as_string, '_refresh'].join('/')
        end
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

      def aggregates
        with_loaded_results { |ds| ds.results[:aggregations] }
      end

      def count
        with_loaded_results { |ds| ds.results[:hits][:total] }
      end

      def load
        clone.tap(&:load!)
      end

      def index(doc)
        synchronize do |conn|
          conn.post \
            path: [single_index, single_type].join('/'),
            body: JSON.dump(doc)
        end
      end

      def load!
        response =
          synchronize do |conn|
            conn.post \
              path: [indices_as_string, types_as_string, '_search'].join('/'),
              body: JSON.dump(to_query)
          end

        unless response.status == 200
          raise "Bad response! #{response.inspect}"
        end

        @results = JSON.parse(response.body, symbolize_names: true)
      end

      def bulk_index(records)
        rows = []

        records.each do |record|
          rows << JSON.dump(index: {})
          rows << JSON.dump(record)
        end

        body = rows.join("\n") << "\n"

        synchronize do |conn|
          conn.post \
            path: [single_index, single_type, '_bulk'].join('/'),
            body: body
        end
      end

      private

      def with_loaded_results
        yield(results ? self : load)
      end

      def symbolize_recursively!(object)
        case object
        when Hash
          object.keys.each do |key|
            object[key.to_sym] = symbolize_recursively!(object.delete(key))
          end
          object
        when Array
          object.map! { |element| symbolize_recursively!(element) }
        else
          object
        end
      end
    end
  end
end
