# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  before do
    TestIndex[:pariah_index_3].create_index

    store [
      {_index: :pariah_index_1, title: "Title 1", comments_count: 1},
      {_index: :pariah_index_1, title: "Title 2", comments_count: 2},
      {_index: :pariah_index_2, title: "Title 3", comments_count: 3},
      {_index: :pariah_index_3, title: "Title 4", comments_count: 4},
    ]
  end

  after { clear_indices }

  describe "#[]" do
    it "should specify the index(es) to be covered by the search" do
      assert_equal [1, 2],    FTS[:pariah_index_1].                 map{|d| d[:comments_count]}.sort
      assert_equal [1, 2, 3], FTS[:pariah_index_1, :pariah_index_2].map{|d| d[:comments_count]}.sort
      assert_equal [1, 2, 4], FTS[:pariah_index_1, :pariah_index_3].map{|d| d[:comments_count]}.sort
      assert_equal [4],       FTS[:pariah_index_1][:pariah_index_3].map{|d| d[:comments_count]}.sort

      # Array as input is fine.
      assert_equal [1, 2, 3], FTS[[:pariah_index_1, :pariah_index_2]].map{|d| d[:comments_count]}.sort
    end

    it "should support passing a callable" do
      current_index = nil
      ds = FTS[->{current_index}]

      current_index = :pariah_index_1
      assert_equal [1, 2], ds.map{|d| d[:comments_count]}.sort

      current_index = :pariah_index_2
      assert_equal [3], ds.map{|d| d[:comments_count]}.sort

      current_index = [:pariah_index_1, :pariah_index_2]
      assert_equal [1, 2, 3], ds.map{|d| d[:comments_count]}.sort
    end
  end

  describe "#append_indices" do
    it "should add the indices to be searched to the current list" do
      assert_equal [1, 2],    FTS.append_index(:pariah_index_1).                   map{|d| d[:comments_count]}.sort
      assert_equal [1, 2, 3], FTS.append_indices(:pariah_index_1, :pariah_index_2).map{|d| d[:comments_count]}.sort
      assert_equal [1, 2, 3], FTS.append_indexes(:pariah_index_1, :pariah_index_2).map{|d| d[:comments_count]}.sort

      assert_equal [1, 2, 3], FTS.append_index(:pariah_index_1).append_index(:pariah_index_2).map{|d| d[:comments_count]}.sort
      assert_equal [3, 4],    FTS[:pariah_index_3].append_index(:pariah_index_2).             map{|d| d[:comments_count]}.sort

      # Array as input is fine.
      assert_equal [1, 2, 3], FTS.append_indices([:pariah_index_1, :pariah_index_2]).map{|d| d[:comments_count]}.sort
    end
  end
end
