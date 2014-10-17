require 'elasticsearch'

require 'fracas/dataset'
require 'fracas/version'

module Fracas
  class << self
    def connect(url = nil)
      Dataset.new(url)
    end
  end
end
