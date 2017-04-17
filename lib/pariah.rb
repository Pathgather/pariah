# frozen_string_literal: true

require 'json'
require 'excon'
require 'pond'

require 'pariah/dataset'
require 'pariah/version'

module Pariah
  class Error < StandardError; end

  class << self
    def connect(url)
      Dataset.new(url)
    end

    def bool(**args)
      Bool.new(**args)
    end
  end
end
