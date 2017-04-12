# frozen_string_literal: true

require 'pariah'
require 'faker'
require 'pry'

FTS = Pariah.connect('http://localhost:9200')

require 'minitest/autorun'
require 'minitest/pride'

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
    hashes = [hashes] unless hashes.is_a?(Array)

    records =
      bodies.map do |body|
        {
          title: Faker::Lorem.sentence,
          body: Faker::Lorem.paragraph,
          tags: Faker::Lorem.words(3),
          published: rand > 0.5,
          comments_count: rand(50),
        }.merge(body)
      end

    FTS[:pariah_test_default].type(:pariah_test).bulk_index(records)
    FTS[:pariah_test_default].refresh
  end

  def clear_indices
    FTS.synchronize do |conn|
      conn.delete(path: 'pariah_test_*')
      conn.put(path: 'pariah_test_default')
    end
  end
end
