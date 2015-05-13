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
        @client.index index: single_index,
                      type:  single_type,
                      id:    doc[:id],
                      body:  doc
      end

      def load!
        @results = @client.search(to_query)
      end

      private

      def with_loaded_results
        yield(results ? self : load)
      end

      def queries
        {
          match_all: {}
        }
      end

      def filters
        filters = @query[:filters]
        if filters.count.zero?
          {
            match_all: {}
          }
        else
          {
            and: filters.map { |w|
              {
                term: w
              }
            }
          }
        end
      end
    end
  end
end
