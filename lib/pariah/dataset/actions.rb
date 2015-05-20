module Pariah
  class Dataset
    module Actions
      def refresh
        @client.indices.refresh index: indices_as_string
      end

      def each(&block)
        with_loaded_results { |ds| ds.all.each(&block) }
      end

      def all
        with_loaded_results { |ds| ds.results[:hits][:hits].map { |hit| hit[:fields] || hit[:_source] } }
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
        if @bulk
          @bulk.push(
            {
              index: {
                _index: single_index,
                _type: single_type,
                _id: doc[:id],
                data: doc
              }
            }
          )
        else
          @client.index index: single_index,
                        type:  single_type,
                        id:    doc[:id],
                        body:  doc
        end
      end

      def load!
        @results = symbolize_recursively!(@client.search(to_query))
      end

      def bulk
        @bulk = []
        yield
        @client.bulk(body: @bulk)
        @bulk = nil
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
