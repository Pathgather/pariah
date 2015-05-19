require 'spec_helper'

describe Pariah::Dataset, "#index" do
  after { clear_indices }

  it "should persist the given document in the given type and index" do
    ds = FTS.from_type(:my_type).from_index(:pariah_test_my_index)

    ds.index title: "My Document", body: "Blah blah blah",   number: 5
    ds.index title: "Another Doc", body: "More stupid text", number: 7
    ds.refresh

    ds.term(number: 5).all.should == [{title: "My Document", body: 'Blah blah blah', number: 5}]
  end

  it "should raise an error if one index isn't specified" do
    ds = FTS.from_type(:my_type)
    proc { ds.index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index/
    proc { ds.from_index(:pariah_test_index1, :pariah_test_index2).index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index/
  end

  it "should raise an error if one type isn't specified" do
    ds = FTS.from_index(:pariah_test_my_index)
    proc { ds.index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type/
    proc { ds.from_type(:type1, :type2).index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type/
  end
end
