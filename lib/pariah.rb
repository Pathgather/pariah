# frozen_string_literal: true

require 'elasticsearch'

require 'pariah/dataset'
require 'pariah/version'

module Pariah
  class << self
    def connect(url_or_client = nil)
      Dataset.new(url_or_client)
    end
  end
end
