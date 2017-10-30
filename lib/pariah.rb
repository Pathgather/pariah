# frozen_string_literal: true

require 'json'
require 'excon'
require 'pond'

require 'pariah/dataset'
require 'pariah/version'

module Pariah
  class Error < StandardError; end

  class << self
    attr_accessor :warning_proc

    def connect(*args)
      Dataset.new(*args)
    end

    def bool(*args)
      Dataset::Bool.new(*args)
    end
  end
end
