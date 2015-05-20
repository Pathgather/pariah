require 'spec_helper'

describe Pariah::Dataset do
  describe "#unfiltered" do
    it "should return a new copy of the dataset with no filter applied" do
      ds1 = FTS.term(comments_count: 5)
      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}

      ds2 = ds1.unfiltered
      ds2.to_query[:body].has_key?(:filter).should == false

      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}
    end
  end
end
