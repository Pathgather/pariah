require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  context "#term" do
    it "should add a filter to the search" do
      store body: {title: "Title 1", comments_count: 5}
      store body: {title: "Title 2", comments_count: 9}
      FTS.refresh

      titles = []
      FTS.term(comments_count: 5).each do |doc|
        titles << doc['title']
      end
      titles.sort.should == ["Title 1"]
    end
  end
end
