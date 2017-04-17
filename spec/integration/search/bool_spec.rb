# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  before do
    store [
      {title: "Title 1", comments_count: 5},
      {title: "Title 2", comments_count: 5},
      {title: "Title 3", comments_count: 5},
      {title: "Title 4", comments_count: 9},
      {title: "Title 5", comments_count: 9},
      {title: "Title 6", comments_count: 9},
    ]
  end

  after { clear_indices }

  describe "#bool" do
    it "should add a bool filter with the given options to the search" do
      assert_equal ["Title 4", "Title 5", "Title 6"],
        FTS.bool(must_not: {term: {comments_count: 5}}).map{|doc| doc[:title]}.sort
    end
  end
end
