# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#term" do
    it "should add a term filter to the search" do
      store_bodies [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
      ]

      assert_equal ["Title 1"], FTS.term(comments_count: 5).map{|doc| doc[:title]}
    end
  end
end
