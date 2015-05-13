require 'pariah'
require 'faker'
require 'pry'

FTS = Pariah.connect

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:expect, :should] }
end

def store(index: 'pariah_test', type: 'pariah_test', body: {})
  FTS.client.index index: index,
                   type: type,
                   body: {
                     title: Faker::Lorem.sentence,
                     body: Faker::Lorem.paragraph,
                     tags: Faker::Lorem.words(3),
                     published: rand > 0.5,
                     comments_count: rand(50)
                   }.merge(body)
end

def clear_indices
  FTS.client.indices.delete index: '_all'
end
