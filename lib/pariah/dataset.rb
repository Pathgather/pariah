# frozen_string_literal: true

require 'pariah/dataset/actions'
require 'pariah/dataset/bool'
require 'pariah/dataset/mutations'
require 'pariah/dataset/query'

module Pariah
  class Dataset
    include Enumerable
    include Mutations
    include Actions
    include Query

    attr_reader :opts, :results

    def initialize(url, excon_options: {})
      @opts = {}
      @pool = Pond.new { Excon.new(url, excon_options) }
    end

    def synchronize(&block)
      @pool.checkout(&block)
    end

    DEFAULT_ALLOWED_CODES = [200]

    def execute_request(
      method:,
      path:,
      body: nil,
      allowed_codes: DEFAULT_ALLOWED_CODES,
      allowed_errors: nil
    )
      path =
        case path
        when Array  then path.compact.join('/')
        when String then path
        else raise Error, "unsupported path argument: #{path.inspect}"
        end

      body =
        case body
        when Hash,   Array    then JSON.dump(body)
        when String, NilClass then body
        else raise Error, "unsupported body argument: #{body.inspect}"
        end

      opts = {
        path: path,
        headers: {'Content-Type' => 'application/json'},
      }

      opts[:body] = body if body

      synchronize do |conn|
        response = conn.send(method, opts)

        if (warning = response.headers["Warning"]) && (p = Pariah.warning_proc)
          p.call(
            warning,
            JSON.parse(body, symbolize_names: true)
          )
        end

        body = JSON.parse(response.body, symbolize_names: true)

        if allowed_errors && reason = body.dig(:error, :reason)
          if allowed_errors.any? { |e| e === reason }
            return false
          end
        end

        unless allowed_codes.include?(response.status)
          raise Error, "unexpected Elasticsearch response: #{response.inspect}"
        end

        body
      end
    end
  end
end
