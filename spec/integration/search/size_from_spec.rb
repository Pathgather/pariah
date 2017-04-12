# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#size and #from" do
    it "should add those arguments to the search" do
      store_bodies [
        {title: "A", col1: 1},
        {title: "B", col1: 2},
        {title: "C", col1: 3},
        {title: "D", col1: 4},
        {title: "E", col1: 5},
        {title: "F", col1: 6},
      ]

      FTS.refresh
      ds = FTS.sort(:col1)
      assert_equal %w(A B C D E F), ds.map{|doc| doc[:title]}
      assert_equal %w(A B C), ds.size(3).map{|doc| doc[:title]}
      assert_equal %w(C D E), ds.size(3).from(2).map{|doc| doc[:title]}
    end
  end
end
