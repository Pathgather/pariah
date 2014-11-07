require 'spec_helper'

describe Fracas::Dataset, '#from_types' do
  after { clear_indices }

  it "should specify the type(s) to be returned by the search" do
    store type: 'type1', body: {title: "Title 1", comments_count: 1}
    store type: 'type1', body: {title: "Title 2", comments_count: 2}
    store type: 'type2', body: {title: "Title 3", comments_count: 3}
    store type: 'type3', body: {title: "Title 4", comments_count: 4}
    FTS.refresh

    FTS.from_types('type1').map{|d| d['comments_count']}.sort.should == [1, 2]
    FTS.from_types('type1', 'type2').map{|d| d['comments_count']}.sort.should == [1, 2, 3]
    FTS.from_types('type1', 'type3').map{|d| d['comments_count']}.sort.should == [1, 2, 4]
    FTS.from_types('type1').from_types('type3').map{|d| d['comments_count']}.sort.should == [1, 2, 4]
  end
end
