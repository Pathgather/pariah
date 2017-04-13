# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#upsert" do
  after { clear_indices }

  it "should support indexing a single document" do
    ds = FTS[:pariah_index_1].type(:pariah_type_1)

    ds.upsert({comments_count: 6})
    ds.refresh

    assert_equal [6], ds.map{|r| r[:comments_count]}.sort
  end

  it "should simply return on an empty input" do
    ds = FTS[:pariah_index_1].type(:pariah_type_1)

    assert_nil ds.upsert([])
    assert_equal [], ds.map{|r| r[:comments_count]}.sort

    assert_nil ds.upsert(nil)
    assert_equal [], ds.map{|r| r[:comments_count]}.sort
  end

  it "should support indexing many documents at once" do
    ds = FTS[:pariah_index_1].type(:pariah_type_1)

    ds.upsert([
      {comments_count: 5},
      {comments_count: 7},
      {comments_count: 2},
      {comments_count: 4},
    ])

    ds.refresh

    assert_equal [2, 4, 5, 7], ds.map{|r| r[:comments_count]}.sort
  end

  it "should not fail when indexing a doc that has a newline in it" do
    ds = FTS[:pariah_index_1].type(:pariah_type_1)

    ds.upsert([
      {title: "Title #1"},
      {title: "Title #2 \n Some more stuff"},
    ])

    ds.refresh

    assert_equal \
      ["Title #1", "Title #2 \n Some more stuff"],
      ds.map{|r| r[:title]}.sort
  end

  it "should respect a specific type field" do
    ds = FTS[:pariah_index_1]

    ds.type(:pariah_type_1).upsert([
      {comments_count: 5},
      {comments_count: 7, type: :pariah_type_2},
    ])

    ds.refresh
    assert_equal [5], ds.type(:pariah_type_1).map{|r| r[:comments_count]}.sort
    assert_equal [7], ds.type(:pariah_type_2).map{|r| r[:comments_count]}.sort
  end

  it "should respect a specific index field" do
    FTS[:pariah_index_1].type(:pariah_type_1).upsert([
      {comments_count: 5},
      {comments_count: 7, index: :pariah_index_2},
    ])

    FTS.refresh
    assert_equal [5], FTS[:pariah_index_1].type(:pariah_type_1).map{|r| r[:comments_count]}.sort
    assert_equal [7], FTS[:pariah_index_2].type(:pariah_type_1).map{|r| r[:comments_count]}.sort
  end
end
