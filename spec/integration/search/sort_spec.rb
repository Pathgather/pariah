# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#sort" do
    before do
      store [
        {title: "A", col1: 1, col2: 3},
        {title: "B", col1: 2, col2: 3},
        {title: "C", col1: 3, col2: 2},
        {title: "D", col1: 4, col2: 2},
        {title: "E", col1: 5, col2: 1},
        {title: "F", col1: 6, col2: 1},
      ]
    end

    it "should add a sort to the search" do
      assert_equal %w(A B C D E F), FTS.sort(:col1).map{|doc| doc[:title]}
      assert_equal %w(A B C D E F), FTS.sort(col1: :asc).map{|doc| doc[:title]}
      assert_equal %w(F E D C B A), FTS.sort(col1: :desc).map{|doc| doc[:title]}
      assert_equal %w(E F C D A B), FTS.sort(:col2, :col1).map{|doc| doc[:title]}
      assert_equal %w(F E D C B A), FTS.sort(:col2, col1: :desc).map{|doc| doc[:title]}
      assert_equal %w(F E D C B A), FTS.sort(col2: :asc, col1: :desc).map{|doc| doc[:title]}
      assert_equal %w(A B C D E F), FTS.sort(col1: :asc, col2: :asc).map{|doc| doc[:title]}
    end

    describe "#search_after" do
      it "should pass the given values to Elasticsearch to search after" do
        assert_equal %w(C D E F),
          FTS.sort(col2: :desc, col1: :asc).
            search_after([3, 2]).map{|doc| doc[:title]}
      end
    end
  end
end
