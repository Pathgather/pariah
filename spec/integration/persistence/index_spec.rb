require 'spec_helper'

describe Pariah::Dataset, "#index" do
  after { clear_indices }

  it "should persist the given document in the given type and index" do
    ds = FTS[:pariah_test_my_index].type(:my_type)

    ds.index title: "My Document", body: "Blah blah blah",   number: 5
    ds.index title: "Another Doc", body: "More stupid text", number: 7
    ds.refresh

    assert_equal [{title: "My Document", body: 'Blah blah blah', number: 5}],
      FTS[:pariah_test_my_index].type(:my_type).term(number: 5).all

    # It's ok to specify an index as a string...
    assert_equal [{title: "My Document", body: 'Blah blah blah', number: 5}],
      FTS['pariah_test_my_index'].type(:my_type).term(number: 5).all

    # ...or as a callable.
    assert_equal [{title: "My Document", body: 'Blah blah blah', number: 5}],
      FTS[->{'pariah_test_my_index'}].type(:my_type).term(number: 5).all
  end

  it "should raise an error if a single index isn't specified" do
    ds = FTS.type(:my_type)

    error = assert_raises(RuntimeError) { ds.index(field: "blah") }
    assert_match(/Need exactly one index/, error.message)

    error = assert_raises(RuntimeError) { ds[:pariah_test_index1, :pariah_test_index2].index(field: "blah") }
    assert_match(/Need exactly one index/, error.message)
  end

  it "should raise an error if a single type isn't specified" do
    ds = FTS[:pariah_test_my_index]

    error = assert_raises(RuntimeError) { ds.index(field: "blah") }
    assert_match(/Need exactly one type/, error.message)

    error = assert_raises(RuntimeError) { ds.types(:type1, :type2).index(field: "blah") }
    assert_match(/Need exactly one type/, error.message)
  end
end
