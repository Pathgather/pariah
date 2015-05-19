require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#from_indices" do
    it "should specify the index(es) to be covered by the search" do
      store index: 'pariah_test_1', body: {title: "Title 1", comments_count: 1}
      store index: 'pariah_test_1', body: {title: "Title 2", comments_count: 2}
      store index: 'pariah_test_2', body: {title: "Title 3", comments_count: 3}
      store index: 'pariah_test_3', body: {title: "Title 4", comments_count: 4}
      FTS.refresh

      FTS.from_indices('pariah_test_1').map{|d| d[:comments_count]}.sort.should == [1, 2]
      FTS.from_indices('pariah_test_1', 'pariah_test_2').map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
      FTS.from_indices('pariah_test_1', 'pariah_test_3').map{|d| d[:comments_count]}.sort.should == [1, 2, 4]
      FTS.from_indices('pariah_test_1').from_indices('pariah_test_3').map{|d| d[:comments_count]}.sort.should == [4]

      # Alias.
      FTS.from_index('pariah_test_1').map{|d| d[:comments_count]}.sort.should == [1, 2]

      # Array as input is fine.
      FTS.from_indices(['pariah_test_1', 'pariah_test_2']).map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
    end
  end

  describe "#append_indices" do
    it "should add the indices to be searched to the current list" do
      store index: 'pariah_test_1', body: {title: "Title 1", comments_count: 1}
      store index: 'pariah_test_1', body: {title: "Title 2", comments_count: 2}
      store index: 'pariah_test_2', body: {title: "Title 3", comments_count: 3}
      store index: 'pariah_test_3', body: {title: "Title 4", comments_count: 4}
      FTS.refresh

      FTS.append_indices('pariah_test_1').map{|d| d[:comments_count]}.sort.should == [1, 2]
      FTS.append_indices('pariah_test_1', 'pariah_test_2').map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
      FTS.append_indices('pariah_test_1').append_indices('pariah_test_2').map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
      FTS.from_indices('pariah_test_3').append_indices('pariah_test_2').map{|d| d[:comments_count]}.sort.should == [3, 4]

      # Alias.
      FTS.append_index('pariah_test_1').map{|d| d[:comments_count]}.sort.should == [1, 2]

      # Array as input is fine.
      FTS.append_indices(['pariah_test_1', 'pariah_test_2']).map{|d| d[:comments_count]}.sort.should == [1, 2, 3]
    end
  end
end
