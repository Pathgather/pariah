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
        with_loaded_results { |ds| ds.results['hits']['hits'].map { |hit| hit['_source'] } }
      end

      def count
        with_loaded_results { |ds| ds.results['hits']['total'] }
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
        @results = @client.search(to_query)
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
    end
  end
end
