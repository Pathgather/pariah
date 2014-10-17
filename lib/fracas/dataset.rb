module Fracas
  class Dataset
    include Enumerable

    attr_reader :client, :query

    def initialize(url)
      @query = {
        indices: [],
        types:   [],
        filters: []
      }

      @client = Elasticsearch::Client.new(url: url)
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
      all.each(&block)
    end

    def all
      @client.search(to_query)['hits']['hits'].map { |hit| hit['_source'] }
    end

    def filter(condition = {})
      merge filters: condition
    end

    def to_query
      query = {
        index: indices,
        type: types,
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

    private

    def indices
      indices = @query[:indices]
      indices.count.zero? ? '_all' : indices.join(',')
    end

    def types
      types = @query[:types]
      types.join(',') unless types.count.zero?
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
