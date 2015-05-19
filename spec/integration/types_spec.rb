require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#type and #types" do
    it "should specify the type(s) to be returned by the search" do
      store type: 'type1', body: {title: "Title 1", comments_count: 1}
      store type: 'type1', body: {title: "Title 2", comments_count: 2}
      store type: 'type2', body: {title: "Title 3", comments_count: 3}
      store type: 'type3', body: {title: "Title 4", comments_count: 4}
      FTS.refresh

      ds = FTS[:pariah_test_default]

      ds.type(:type1).map{|d| d[:comments_count]}.sort.should == [1, 2]
      ds.types(:type1, :type2).map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
      ds.types(:type1, :type3).map{|d| d[:comments_count]}.sort.should == [1, 2, 4]
      ds.type(:type1).type(:type3).map{|d| d[:comments_count]}.sort.should == [4]

      # Array as input is fine.
      FTS.types([:type1, :type2]).map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
    end
  end

  describe "#append_type and #append_types" do
    it "should add the indices to be searched to the current list" do
      store type: 'type1', body: {title: "Title 1", comments_count: 1}
      store type: 'type1', body: {title: "Title 2", comments_count: 2}
      store type: 'type2', body: {title: "Title 3", comments_count: 3}
      store type: 'type3', body: {title: "Title 4", comments_count: 4}
      FTS.refresh

      ds = FTS[:pariah_test_default]

      ds.append_type(:type1).map{|d| d[:comments_count]}.sort.should == [1, 2]
      ds.append_types(:type1, :type2).map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
      ds.append_types(:type1, :type3).map{|d| d[:comments_count]}.sort.should == [1, 2, 4]
      ds.type(:type1).append_type(:type3).map{|d| d[:comments_count]}.sort.should == [1, 2, 4]

      # Array as input is fine.
      ds.append_types([:type1, :type2]).map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
    end
  end
end
