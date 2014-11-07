module Fracas
  class Dataset
    module Actions
      def refresh
        @client.indices.refresh index: indices
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

      def to_query
        query = {
          index: indices.join(','),
          type: types.join(','),
          body: {
            query: queries,
            filter: filters
          }
        }
      end

      def add_percolator(id)
        i = indices
        raise "Need exactly one index for a percolator, attempted to use: #{i.inspect}" unless i.length == 1 and i.first != '_all'

        @client.index index: i.first,
                      type:  '.percolator',
                      id:    id,
                      body: {
                        query: queries,
                        filter: filters
                      }
      end

      def percolate(doc)
        i = indices
        raise "Need exactly one index for a percolator, attempted to use: #{i.inspect}" unless i.length == 1 and i.first != '_all'

        result = @client.percolate index: i.first,
                                   type: 'what-goes-here-doesnt-matter',
                                   body: {
                                     doc: doc
                                   }

        result['matches'].map { |match| match['_id'] }
      end

      def load
        clone.tap(&:load!)
      end

      def load!
        @results = @client.search(to_query)
      end

      def index(doc)
        i = indices
        t = types

        raise "Need exactly one index for a document, attempted to use: #{i.inspect}" unless i.length == 1 and i.first != '_all'
        raise "Need exactly one type for a document, attempted to use: #{t.inspect}" unless t.length == 1

        @client.index index: i.first,
                      type:  t.first,
                      id:    doc[:id],
                      body:  doc
      end

      def with_loaded_results
        yield results ? self : load
      end

      def indices
        if (indices = @query[:indices]).empty?
          ['_all']
        else
          indices
        end
      end

      def types
        @query[:types]
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
