require 'spec_helper'

describe Pariah::Dataset, "#percolate" do
  after { clear_indices }

  it "when matching percolators are defined should return those percolators" do
    FTS.from_index('pariah_test_my_index').filter(number: 5).add_percolator('my_percolator')

    proc { FTS.from_index('pariah_test_index1', 'pariah_test_index2').filter(number: 5).add_percolator('my_percolator') }.should raise_error RuntimeError, /Need exactly one index/
    proc { FTS.filter(number: 5).add_percolator('my_percolator') }.should raise_error RuntimeError, /Need exactly one index/

    FTS.from_index('pariah_test_my_index').percolate(number: 5).should == ['my_percolator']
  end
end
