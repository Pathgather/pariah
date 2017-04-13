# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#index" do
  after { clear_indices }

  it "should support indexing a single document" do
    ds = FTS[:pariah_test_default].type(:pariah_test)

    ds.index({comments_count: 6})
    ds.refresh

    assert_equal [6], ds.map{|r| r[:comments_count]}.sort
  end

  it "should simply return on an empty input" do
    ds = FTS[:pariah_test_default].type(:pariah_test)

    assert_nil ds.index([])
    assert_equal [], ds.map{|r| r[:comments_count]}.sort

    assert_nil ds.index(nil)
    assert_equal [], ds.map{|r| r[:comments_count]}.sort
  end

  it "should support indexing many documents at once" do
    ds = FTS[:pariah_test_default].type(:pariah_test)

    ds.index([
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

    ds.index([
      {title: "Title #1"},
      {title: "Title #2 \n Some more stuff"},
    ])

    ds.refresh

    assert_equal \
      ["Title #1", "Title #2 \n Some more stuff"],
      ds.map{|r| r[:title]}.sort
  end
end
