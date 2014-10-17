require 'elasticsearch'

require 'fracas/cluster'
require 'fracas/version'

module Fracas
  class << self
    def connect(url = nil)
      Cluster.new(url)
    end
  end
end
