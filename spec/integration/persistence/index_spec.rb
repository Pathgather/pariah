# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#index" do
  after { clear_indices }

  it "should persist the given document in the given type and index" do
    ds = TestIndex.type(:pariah_test)

    ds.index title: "My Document", body: "Blah blah blah",   comments_count: 5
    ds.index title: "Another Doc", body: "More stupid text", comments_count: 7
    ds.refresh

    assert_equal [{title: "My Document", body: 'Blah blah blah', comments_count: 5}],
      TestIndex.type(:pariah_test).term(comments_count: 5).all
  end

  it "should raise an error if a single index isn't specified" do
    ds = FTS.type(:pariah_test)

    error = assert_raises(RuntimeError) { ds.index(field: "blah") }
    assert_match(/Need exactly one index/, error.message)

    error = assert_raises(RuntimeError) { ds[:pariah_test_index1, :pariah_test_index2].index(field: "blah") }
    assert_match(/Need exactly one index/, error.message)
  end

  it "should raise an error if a single type isn't specified" do
    ds = FTS[:pariah_test_index]

    error = assert_raises(RuntimeError) { ds.index(field: "blah") }
    assert_match(/Need exactly one type/, error.message)

    error = assert_raises(RuntimeError) { ds.types(:type1, :type2).index(field: "blah") }
    assert_match(/Need exactly one type/, error.message)
  end
end
