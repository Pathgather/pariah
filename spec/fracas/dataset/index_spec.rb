require 'spec_helper'

describe Fracas::Dataset, "#index" do
  it "should persist the given document in the given type and index" do
    FTS.from_type('my_type').from_index('my_index').index title: "My Document", body: "Blah blah blah",   number: 5
    FTS.from_type('my_type').from_index('my_index').index title: "Another Doc", body: "More stupid text", number: 7
    FTS.refresh

    FTS.from_type('my_type').from_index('my_index').filter(number: 5).all.should == [{'title' => "My Document", 'body' => 'Blah blah blah', 'number' => 5}]
  end

  it "should raise an error if one index isn't specified" do
    proc { FTS.from_type('my_type').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index for a document/
    proc { FTS.from_type('my_type').from_index('index1', 'index2').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one index for a document/
  end

  it "should raise an error if one type isn't specified" do
    proc { FTS.from_index('my_index').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type for a document/
    proc { FTS.from_index('my_index').from_type('type1', 'type2').index(field: "blah") }.should raise_error RuntimeError, /Need exactly one type for a document/
  end
end
