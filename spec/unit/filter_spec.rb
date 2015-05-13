require 'spec_helper'

describe Pariah::Dataset do
  it "with no filter should resolve to a filter that matches everything" do
    FTS.to_query[:body][:filter].should == {match_all: {}}
  end

  describe "#filter" do
    it "should return a new copy of the dataset with the filter applied" do
      ds1 = FTS.filter(comments_count: 5)
      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}

      ds2 = ds1.filter(title: "The Joy of Ferrets")
      ds2.to_query[:body][:filter].should == {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}

      # Original dataset left unchanged?
      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}
    end
  end

  describe "#unfiltered" do
    it "should return a new copy of the dataset with no filter applied" do
      ds1 = FTS.filter(comments_count: 5)
      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}

      ds2 = ds1.unfiltered
      ds2.to_query[:body][:filter].should == {match_all: {}}

      ds1.to_query[:body][:filter].should == {term: {comments_count: 5}}
    end
  end
end
