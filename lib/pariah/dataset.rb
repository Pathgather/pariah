require 'pariah/dataset/mutations'
require 'pariah/dataset/actions'
require 'pariah/dataset/query'

module Pariah
  class Dataset
    include Enumerable
    include Mutations
    include Actions
    include Query

    attr_reader :client, :query, :results

    def initialize(url_or_client)
      @bulk   = nil
      @query  = {}
      @client =
        if url_or_client.is_a?(Elasticsearch::Transport::Client)
          url_or_client
        else
          Elasticsearch::Client.new(url: url_or_client)
        end
    end
  end
end
