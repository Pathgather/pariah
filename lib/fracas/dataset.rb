module Fracas
  class Dataset
    include Enumerable

    attr_reader :client, :query, :results

    def initialize(url_or_client)
      @query = {
        indices: [],
        types:   [],
        filters: []
      }

      @client = if url_or_client.is_a?(Elasticsearch::Transport::Client)
                  url_or_client
                else
                  Elasticsearch::Client.new(url: url_or_client)
                end
    end

    def refresh
      @client.indices.refresh index: indices
    end

    def from_indices(*indices)
      merge(indices: indices)
    end
    alias :from_index :from_indices

    def from_types(*types)
      merge(types: types)
    end
    alias :from_type :from_types

    def each(&block)
      with_loaded_results { |ds| ds.all.each(&block) }
    end

    def all
      with_loaded_results { |ds| ds.results['hits']['hits'].map { |hit| hit['_source'] } }
    end

    def count
      with_loaded_results { |ds| ds.results['hits']['total'] }
    end

    def filter(condition = {})
      merge filters: condition
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

    private

    def with_loaded_results
      yield results ? self : load
    end

    def indices
      indices = @query[:indices]
      if indices.count.zero?
        ['_all']
      else
        indices
      end
    end

    def types
      types = @query[:types]
      if types.count.zero?
        []
      else
        types
      end
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
