module Fracas
  class Cluster
    attr_reader :client

    def initialize(url)
      @client = Elasticsearch::Client.new(url: url)
    end
  end
end
