require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#size and #from" do
    it "should add those arguments to the search" do
      store body: {title: "A", col1: 1}
      store body: {title: "B", col1: 2}
      store body: {title: "C", col1: 3}
      store body: {title: "D", col1: 4}
      store body: {title: "E", col1: 5}
      store body: {title: "F", col1: 6}

      FTS.refresh
      ds = FTS.sort(:col1)
      ds.map{|doc| doc[:title]}.should == %w(A B C D E F)
      ds.size(3).map{|doc| doc[:title]}.should == %w(A B C)
      ds.size(3).from(2).map{|doc| doc[:title]}.should == %w(C D E)
    end
  end
end
