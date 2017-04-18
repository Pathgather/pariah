# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  before do
    store [
      {_type: 'pariah_type_1', title: "Title 1", comments_count: 1},
      {_type: 'pariah_type_1', title: "Title 2", comments_count: 2},
      {_type: 'pariah_type_2', title: "Title 3", comments_count: 3},
      {_type: 'pariah_type_2', title: "Title 4", comments_count: 4},
    ]
  end

  after { clear_indices }

  describe "#type and #types" do
    it "should specify the type(s) to be returned by the search" do
      ds = FTS[:pariah_index_1]

      assert_equal [1, 2],       ds.type(:pariah_type_1).map{|d| d[:comments_count]}.sort
      assert_equal [1, 2, 3, 4], ds.types(:pariah_type_1, :pariah_type_2).map{|d| d[:comments_count]}.sort
      assert_equal [3, 4],       ds.types(:pariah_type_2).map{|d| d[:comments_count]}.sort
      assert_equal [3, 4],       ds.types(:pariah_type_1).types(:pariah_type_2).map{|d| d[:comments_count]}.sort

      # Array as input is fine.
      assert_equal [1, 2, 3, 4], FTS.types([:pariah_type_1, :pariah_type_2]).map{|d| d[:comments_count]}.sort
    end
  end

  describe "#append_type and #append_types" do
    it "should add the indices to be searched to the current list" do
      ds = FTS[:pariah_index_1]

      assert_equal [1, 2], ds.append_type(:pariah_type_1).map{|d| d[:comments_count]}.sort
      assert_equal [1, 2, 3, 4], ds.append_types(:pariah_type_1, :pariah_type_2).map{|d| d[:comments_count]}.sort
      assert_equal [1, 2, 3, 4], ds.type(:pariah_type_1).append_type(:pariah_type_2).map{|d| d[:comments_count]}.sort

      # Array as input is fine.
      assert_equal [1, 2, 3, 4], ds.append_types([:pariah_type_1, :pariah_type_2]).map{|d| d[:comments_count]}.sort
    end
  end
end
