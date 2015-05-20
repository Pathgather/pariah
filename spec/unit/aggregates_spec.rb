require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  context "#aggregate" do
    it "specifies a list of fields to aggregate on" do
      ds = FTS[:pariah_test_default].aggregate(:a, :b)

      ds.to_query[:body][:aggs].should == {a: {terms: {field: :a}}, b: {terms: {field: :b}}}
    end
  end
end
