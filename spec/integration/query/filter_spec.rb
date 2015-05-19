require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  context "#term" do
    it "should add a term filter to the search" do
      store_bodies [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
      ]

      FTS.term(comments_count: 5).map{|doc| doc[:title]}.should == ["Title 1"]
    end
  end
end
