require 'spec_helper'

describe Pariah::Dataset, "#bulk" do
  after { clear_indices }

  it "should allow many write operations to be run in bulk" do
    ds = FTS.from_type('my_type').from_index('pariah_test_my_index')

    ds.bulk do
      ds.index number: 5
      ds.index number: 7
      ds.index number: 2
      ds.index number: 4
    end

    FTS.refresh

    FTS.from_type('my_type').from_index('pariah_test_my_index').map{|r| r['number']}.sort.should == [2, 4, 5, 7]
  end
end
