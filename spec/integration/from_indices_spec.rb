require 'spec_helper'

describe Pariah::Dataset, '#from_indices' do
  after { clear_indices }

  it "should specify the index(es) to be covered by the search" do
    store index: 'pariah_test_1', body: {title: "Title 1", comments_count: 1}
    store index: 'pariah_test_1', body: {title: "Title 2", comments_count: 2}
    store index: 'pariah_test_2', body: {title: "Title 3", comments_count: 3}
    store index: 'pariah_test_3', body: {title: "Title 4", comments_count: 4}
    FTS.refresh

    FTS.from_indices('pariah_test_1').map{|d| d['comments_count']}.sort.should == [1, 2]
    FTS.from_indices('pariah_test_1', 'pariah_test_2').map{|d| d['comments_count']}.sort.should == [1, 2, 3]
    FTS.from_indices('pariah_test_1', 'pariah_test_3').map{|d| d['comments_count']}.sort.should == [1, 2, 4]
    FTS.from_indices('pariah_test_1').from_indices('pariah_test_3').map{|d| d['comments_count']}.sort.should == [1, 2, 4]
  end
end
