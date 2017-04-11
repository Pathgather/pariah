require 'spec_helper'

describe Pariah::Dataset, "#bulk" do
  after { clear_indices }

  it "should allow many write operations to be run in bulk" do
    ds = FTS[:pariah_test_default].type(:my_type)

    ds.bulk do
      ds.index number: 5
      ds.index number: 7
      ds.index number: 2
      ds.index number: 4
    end

    ds.refresh

    assert_equal [2, 4, 5, 7], ds.map{|r| r[:number]}.sort
  end
end
