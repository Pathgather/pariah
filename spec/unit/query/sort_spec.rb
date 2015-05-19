require 'spec_helper'

describe Pariah::Dataset do
  describe "#sort" do
    it "should return a new copy of the dataset with the filter applied" do
      ds1 = FTS.sort(:a)
      ds1.to_query[:body][:sort].should == [:a]

      ds2 = ds1.sort(:b, blah: :desc)
      ds2.to_query[:body][:sort].should == [:b, {blah: :desc}]

      ds3 = ds2.sort(:b, {blah: :desc}, :c, {t: :asc})
      ds3.to_query[:body][:sort].should == [:b, {blah: :desc}, :c, {t: :asc}]

      # Original dataset left unchanged?
      ds1.to_query[:body][:sort].should == [:a]
    end
  end
end
