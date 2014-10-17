require 'spec_helper'

describe Fracas::Dataset, '#from_indices' do
  it "should specify the index(es) to be covered by the search" do
    store index: 'index1', body: {title: "Title 1", comments_count: 1}
    store index: 'index1', body: {title: "Title 2", comments_count: 2}
    store index: 'index2', body: {title: "Title 3", comments_count: 3}
    store index: 'index3', body: {title: "Title 4", comments_count: 4}
    FTS.refresh

    FTS.from_indices('index1').map{|d| d['comments_count']}.sort.should == [1, 2]
    FTS.from_indices('index1', 'index2').map{|d| d['comments_count']}.sort.should == [1, 2, 3]
    FTS.from_indices('index1', 'index3').map{|d| d['comments_count']}.sort.should == [1, 2, 4]
    FTS.from_indices('index1').from_indices('index3').map{|d| d['comments_count']}.sort.should == [1, 2, 4]
  end
end
