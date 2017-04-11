require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#each" do
    it "should iterate over the JSON documents matching the search" do
      store_bodies [{title: "Title 1"}, {title: "Title 2"}]

      titles = []
      FTS[:pariah_test_default].each do |doc|
        titles << doc[:title]
      end
      assert_equal ["Title 1", "Title 2"], titles.sort

      # Correct return result from #each?
      assert_equal ["Title 1", "Title 2"], FTS[:pariah_test_default].each{|d| d}.map{|h| h[:title]}.sort
    end

    it "should not load the results into the dataset on which it is called" do
      store_bodies [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
        {title: "Title 3", comments_count: 5},
      ]

      ds = FTS[:pariah_test_default].term(comments_count: 5)
      assert_nil ds.results

      titles = []
      ds.each { |doc| titles << doc[:title] }
      assert_equal ["Title 1", "Title 3"], titles.sort

      assert_nil ds.results
    end

    it "should allow for the use of Enumerable methods" do
      store_bodies [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
        {title: "Title 3", comments_count: 5},
      ]

      ds = FTS[:pariah_test_default]
      assert_nil ds.results
      assert_equal [5, 5, 9], ds.map{|doc| doc[:comments_count]}.sort
      assert_equal 19, ds.inject(0){|number, doc| number + doc[:comments_count]}
      assert_nil ds.results
    end
  end

  describe "#all" do
    it "should return an array of matching documents without mutating the dataset" do
      store_bodies [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
        {title: "Title 3", comments_count: 5},
      ]

      ds = FTS[:pariah_test_default].term(comments_count: 5)
      assert_nil ds.results

      all = ds.all
      assert_equal 2, all.length
      assert_equal ["Title 1", "Title 3"], all.map{|d| d[:title]}.sort

      assert_nil ds.results
    end
  end

  describe "#count" do
    it "should return a count of matching documents without mutating the dataset" do
      store_bodies [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
        {title: "Title 3", comments_count: 5},
      ]

      ds = FTS[:pariah_test_default].term(comments_count: 5)
      assert_nil ds.results
      assert_equal 2, ds.count
      assert_nil ds.results
    end
  end

  describe "#load" do
    it "should copy the dataset and load the results into it" do
      store_bodies [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
        {title: "Title 3", comments_count: 5},
      ]

      ds1 = FTS[:pariah_test_default].term(comments_count: 5)
      assert_nil ds1.results

      ds2 = ds1.load
      refute_nil ds2.results

      assert_equal 2, ds2.count
      assert_equal 2, ds2.all.length

      assert_nil ds1.results
    end
  end
end
