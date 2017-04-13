# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#index" do
  after { clear_indices }

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
end
