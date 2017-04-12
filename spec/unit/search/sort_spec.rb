# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  describe "#sort" do
    it "should return a new copy of the dataset with the filter applied" do
      ds1 = FTS.sort(:a)
      assert_equal [:a], ds1.to_query[:sort]

      ds2 = ds1.sort(:b, blah: :desc)
      assert_equal [:b, {blah: :desc}], ds2.to_query[:sort]

      ds3 = ds2.sort(:b, {blah: :desc}, :c, {t: :asc})
      assert_equal [:b, {blah: :desc}, :c, {t: :asc}], ds3.to_query[:sort]

      # Original dataset left unchanged?
      assert_equal [:a], ds1.to_query[:sort]
    end
  end
end
