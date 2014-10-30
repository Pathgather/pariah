require 'elasticsearch'

require 'fracas/dataset'
require 'fracas/version'

module Fracas
  class << self
    def connect(url_or_client = nil)
      Dataset.new(url_or_client)
    end
  end
end
