# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#delete" do
  before do
    store [
      {title: "Title 1", comments_count: 5},
      {title: "Title 2", comments_count: 9},
      {title: "Title 3", comments_count: 5},
    ]
  end

  after { clear_indices }

  it "should support deleting records that match a query" do
    ds = FTS[:pariah_index_1].type(:pariah_type_1)

    assert_equal [5, 5, 9], ds.map{|r| r[:comments_count]}.sort

    ds.filter(term: {comments_count: 5}).delete
    ds.refresh

    assert_equal [9], ds.map{|r| r[:comments_count]}
  end
end
