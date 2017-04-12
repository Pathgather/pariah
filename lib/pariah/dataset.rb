# frozen_string_literal: true

require 'pariah/dataset/mutations'
require 'pariah/dataset/actions'
require 'pariah/dataset/query'

module Pariah
  class Dataset
    include Enumerable
    include Mutations
    include Actions
    include Query

    attr_reader :query, :results

    def initialize(url)
      @bulk  = nil
      @query = {}

      @pool =
        Pond.new do
          Excon.new(
            url,
            persistent: true,
            headers: { 'Content-Type' => 'application/json' }
          )
        end

      # Ensure that the connection is good.
      synchronize do |conn|
        r = conn.get(path: '_cluster/health')
        raise "Bad Elasticsearch connection!" unless r.status == 200
      end
    end

    def synchronize(&block)
      @pool.checkout(&block)
    end
  end
end
