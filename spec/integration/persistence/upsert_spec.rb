# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#upsert" do
  after { clear_indices }

  it "should support indexing a single document" do
    ds = FTS[:pariah_test_default].type(:pariah_test)

    ds.upsert({comments_count: 6})
    ds.refresh

    assert_equal [6], ds.map{|r| r[:comments_count]}.sort
  end

  it "should simply return on an empty input" do
    ds = FTS[:pariah_test_default].type(:pariah_test)

    assert_nil ds.upsert([])
    assert_equal [], ds.map{|r| r[:comments_count]}.sort

    assert_nil ds.upsert(nil)
    assert_equal [], ds.map{|r| r[:comments_count]}.sort
  end

  it "should support indexing many documents at once" do
    ds = FTS[:pariah_test_default].type(:pariah_test)

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
    ds = FTS[:pariah_test_default].type(:pariah_test)

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
    ds = FTS[:pariah_test_default]

    ds.type(:pariah_test).upsert([
      {comments_count: 5},
      {comments_count: 7, type: :pariah_test_2},
    ])

    ds.refresh
    assert_equal [5], ds.type(:pariah_test).  map{|r| r[:comments_count]}.sort
    assert_equal [7], ds.type(:pariah_test_2).map{|r| r[:comments_count]}.sort
  end

  it "should respect a specific index field" do
    TestIndex[:pariah_test_2].create_index

    FTS[:pariah_test_default].type(:pariah_test).upsert([
      {comments_count: 5},
      {comments_count: 7, index: :pariah_test_2},
    ])

    FTS.refresh
    assert_equal [5], FTS[:pariah_test_default].type(:pariah_test).map{|r| r[:comments_count]}.sort
    assert_equal [7], FTS[:pariah_test_2].type(:pariah_test).map{|r| r[:comments_count]}.sort
  end
end
