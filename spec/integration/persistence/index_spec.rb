require 'spec_helper'

describe Pariah::Dataset, "#index" do
  after { clear_indices }

  it "should persist the given document in the given type and index" do
    ds = FTS[:pariah_test_my_index].type(:my_type)

    ds.index title: "My Document", body: "Blah blah blah",   number: 5
    ds.index title: "Another Doc", body: "More stupid text", number: 7
    ds.refresh

    FTS[:pariah_test_my_index].type(:my_type).term(number: 5).all.should == [{title: "My Document", body: 'Blah blah blah', number: 5}]
  end

  it "should raise an error if a single index isn't specified" do
    ds = FTS.type(:my_type)

    proc { ds.index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index/
    proc { ds[:pariah_test_index1, :pariah_test_index2].index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index/
  end

  it "should raise an error if a single type isn't specified" do
    ds = FTS[:pariah_test_my_index]

    proc { ds.index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type/
    proc { ds.types(:type1, :type2).index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type/
  end
end
