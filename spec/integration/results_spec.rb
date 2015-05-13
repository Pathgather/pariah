require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  context "#each" do
    it "should iterate over the JSON documents matching the search" do
      store body: {title: "Title 1"}
      store body: {title: "Title 2"}
      FTS.refresh

      titles = []
      FTS.each do |doc|
        titles << doc['title']
      end
      titles.sort.should == ["Title 1", "Title 2"]

      FTS.each{|d| d}.should == FTS.all
    end

    it "should not load the results into the dataset on which it is called" do
      store body: {title: "Title 1", comments_count: 5}
      store body: {title: "Title 2", comments_count: 9}
      store body: {title: "Title 3", comments_count: 5}
      FTS.refresh
      ds = FTS.filter(comments_count: 5)
      ds.results.should be_nil

      titles = []
      ds.each { |doc| titles << doc['title'] }
      titles.sort.should == ["Title 1", "Title 3"]

      ds.results.should be_nil
    end

    it "should allow for the use of Enumerable methods" do
      store body: {title: "Title 1", comments_count: 5}
      store body: {title: "Title 2", comments_count: 9}
      store body: {title: "Title 3", comments_count: 5}
      FTS.refresh
      ds = FTS.filter(comments_count: 5)
      ds.results.should be_nil
      ds.inject(0){|number, doc| number + doc['comments_count']}.should == 10
      ds.results.should be_nil
    end
  end

  context "#all" do
    it "should return an array of matching documents without mutating the dataset" do
      store body: {title: "Title 1", comments_count: 5}
      store body: {title: "Title 2", comments_count: 9}
      store body: {title: "Title 3", comments_count: 5}
      FTS.refresh
      ds = FTS.filter(comments_count: 5)
      ds.results.should be_nil
      all = ds.all
      all.length.should == 2
      all.map{|d| d['title']}.sort.should == ["Title 1", "Title 3"]
      ds.results.should be_nil
    end
  end

  context "#count" do
    it "should return a count of matching documents without mutating the dataset" do
      store body: {title: "Title 1", comments_count: 5}
      store body: {title: "Title 2", comments_count: 9}
      store body: {title: "Title 3", comments_count: 5}
      FTS.refresh

      ds = FTS.filter(comments_count: 5)
      ds.results.should be_nil
      ds.count.should == 2
      ds.results.should be_nil
    end
  end

  context "#load" do
    it "should copy the dataset and load the results into it" do
      store body: {title: "Title 1", comments_count: 5}
      store body: {title: "Title 2", comments_count: 9}
      store body: {title: "Title 3", comments_count: 5}
      FTS.refresh
      ds1 = FTS.filter(comments_count: 5)
      ds1.results.should be_nil

      ds2 = ds1.load
      ds2.results.should_not be_nil

      ds2.count.should == 2
      ds2.all.length.should == 2

      ds1.results.should be_nil
    end
  end
end
