require 'fracas'

FTS = Fracas.connect

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:expect, :should] }
end
