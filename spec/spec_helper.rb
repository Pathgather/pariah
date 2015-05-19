require 'pariah'
require 'faker'
require 'pry'

FTS = Pariah.connect

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:expect, :should] }
end

def store(hashes)
  hashes = [hashes] unless hashes.is_a?(Array)
  merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }

  hashes.each do |hash|
    full_doc = {
      index: :pariah_test_default,
      type: :pariah_test,
      body: {
        title: Faker::Lorem.sentence,
        body: Faker::Lorem.paragraph,
        tags: Faker::Lorem.words(3),
        published: rand > 0.5,
        comments_count: rand(50),
      },
    }

    FTS.client.index(full_doc.merge(hash, &merger))
  end

  FTS.refresh
end

def store_bodies(bodies)
  store bodies.map { |body| {body: body} }
end

def clear_indices
  FTS.client.indices.delete index: 'pariah_test_*'
end
