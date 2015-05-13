require 'spec_helper'

describe Pariah::Dataset do
  describe "#filter" do
    it "should return a new copy of the dataset with the filter applied" do
      ds1 = FTS.filter(comments_count: 5)
      ds1.query[:filters].should == [{comments_count: 5}]

      ds2 = ds1.filter(title: "The Joy of Ferrets")
      ds2.query[:filters].should == [{comments_count: 5}, {title: "The Joy of Ferrets"}]

      ds1.query[:filters].should == [{comments_count: 5}]
    end
  end

  describe "#unfiltered" do
    it "should return a new copy of the dataset with no filter applied" do
      ds1 = FTS.filter(comments_count: 5)
      ds1.query[:filters].should == [{comments_count: 5}]

      ds2 = ds1.unfiltered
      ds2.query[:filters].should == []

      ds1.query[:filters].should == [{comments_count: 5}]
    end
  end
end
