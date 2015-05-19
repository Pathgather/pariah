require 'spec_helper'

describe Pariah::Dataset do
  it "with no filter have no filter param in the output" do
    FTS.to_query[:body].has_key?(:filter).should == false
  end

  describe "#term" do
    it "should return a new copy of the dataset with the term filter applied" do
      ds1 = FTS.term(comments_count: 5)
      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}

      ds2 = ds1.term(title: "The Joy of Ferrets")
      ds2.to_query[:body][:filter].should == {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}

      ds3 = ds2.term(another_column: "another value")
      ds3.to_query[:body][:filter].should == {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}, {term: {another_column: "another value"}}]}

      # Original datasets left unchanged?
      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}
      ds2.to_query[:body][:filter].should == {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}
    end
  end

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
