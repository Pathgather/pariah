# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#bulk_index" do
  after { clear_indices }

  it "should allow many write operations to be run in bulk" do
    ds = FTS[:pariah_test_default].type(:my_type)

    ds.bulk_index([{number: 5}, {number: 7}, {number: 2}, {number: 4}])
    ds.refresh

    assert_equal [2, 4, 5, 7], ds.map{|r| r[:number]}.sort
  end
end
