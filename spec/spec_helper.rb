# frozen_string_literal: true

require 'pariah'
require 'faker'
require 'pry'

FTS = Pariah.connect('http://localhost:9200')

require 'minitest/autorun'
require 'minitest/pride'

FTS['pariah_*'].drop_index

TestIndex =
  FTS[:pariah_index_1].
    set_index_schema(
      settings: {
        index: {
          number_of_shards: 1,
          number_of_replicas: 0,
        }
      },
      mappings: {
        pariah_type_1: {
          properties: {
            title:          {type: 'text'},
            body:           {type: 'text'},
            topic:          {type: 'keyword'},
            tags:           {type: 'keyword'},
            published:      {type: 'boolean'},
            comments_count: {type: 'integer'},
          }
        },
        pariah_type_2: {
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
    records = [records] unless records.is_a?(Array)

    records =
      records.map do |record|
        {
          title: Faker::Lorem.sentence,
          body: Faker::Lorem.paragraph,
          topic: Faker::Lorem.word,
          tags: Faker::Lorem.words(3),
          published: rand > 0.5,
          comments_count: rand(50),
        }.merge(record)
      end

    FTS[:pariah_index_1].type(:pariah_type_1).upsert(records)
    FTS.refresh
  end

  def clear_indices
    FTS['pariah_index_*'].drop_index
    TestIndex.create_index
    TestIndex[:pariah_index_2].create_index
    FTS.refresh
  end
end
