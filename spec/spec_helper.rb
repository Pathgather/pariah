# frozen_string_literal: true

require 'pariah'
require 'faker'
require 'pry'

FTS = Pariah.connect('http://localhost:9200')

require 'minitest/autorun'
require 'minitest/pride'

TestIndex =
  FTS[:pariah_test_default].
    set_index_schema(
      settings: {
        index: {
          number_of_shards: 1,
          number_of_replicas: 0,
        }
      },
      mappings: {
        pariah_test: {
          properties: {
            title:          {type: 'text'},
            body:           {type: 'text'},
            topic:          {type: 'keyword'},
            tags:           {type: 'keyword'},
            published:      {type: 'boolean'},
            comments_count: {type: 'integer'},
          }
        },
        pariah_test_2: {
          properties: {
            title:          {type: 'text'},
            body:           {type: 'text'},
            topic:          {type: 'keyword'},
            tags:           {type: 'keyword'},
            published:      {type: 'boolean'},
            comments_count: {type: 'integer'},
          }
        },
      }
    )

TestIndex.create_index

class PariahSpec < Minitest::Spec
  register_spec_type(//, self)

  def assert_filter(ds, expected)
    actual = ds.to_query[:query][:bool][:filter]
    if expected.nil?
      assert_nil expected
    else
      assert_equal expected, actual
    end
  end

  def store(records)
    rows = []

    records.each do |record|
      i = record[:index] || :pariah_test_default
      t = record[:type]  || :pariah_test

      rows << JSON.dump(index: {_index: i, _type: t})
      rows << JSON.dump(record[:body])
    end

    body = rows.join("\n") << "\n"

    FTS.synchronize do |conn|
      conn.post \
        path: '_bulk',
        body: body
    end

    FTS.refresh
  end

  def store_bodies(bodies)
    bodies = [bodies] unless bodies.is_a?(Array)

    records =
      bodies.map do |body|
        {
          title: Faker::Lorem.sentence,
          body: Faker::Lorem.paragraph,
          topic: Faker::Lorem.word,
          tags: Faker::Lorem.words(3),
          published: rand > 0.5,
          comments_count: rand(50),
        }.merge(body)
      end

    FTS[:pariah_test_default].type(:pariah_test).upsert(records)
    FTS[:pariah_test_default].refresh
  end

  def clear_indices
    FTS['pariah_test_*'].drop_index
    TestIndex.create_index
    FTS.refresh
  end
end
