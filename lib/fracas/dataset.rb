module Fracas
  class Dataset
    attr_reader :client

    def initialize(url)
      @client = Elasticsearch::Client.new(url: url)
    end
  end
end
