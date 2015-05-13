require 'spec_helper'

describe Pariah::Dataset, "#index" do
  after { clear_indices }

  it "should persist the given document in the given type and index" do
    FTS.from_type('my_type').from_index('pariah_test_my_index').index title: "My Document", body: "Blah blah blah",   number: 5
    FTS.from_type('my_type').from_index('pariah_test_my_index').index title: "Another Doc", body: "More stupid text", number: 7
    FTS.refresh

    FTS.from_type('my_type').from_index('pariah_test_my_index').filter(number: 5).all.should == [{'title' => "My Document", 'body' => 'Blah blah blah', 'number' => 5}]
  end

  it "should raise an error if one index isn't specified" do
    proc { FTS.from_type('my_type').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index/
    proc { FTS.from_type('my_type').from_index('pariah_test_index1', 'pariah_test_index2').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index/
  end

  it "should raise an error if one type isn't specified" do
    proc { FTS.from_index('pariah_test_my_index').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type/
    proc { FTS.from_index('pariah_test_my_index').from_type('type1', 'type2').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type/
  end
end
