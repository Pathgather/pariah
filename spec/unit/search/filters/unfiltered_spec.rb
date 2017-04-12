# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  describe "#unfiltered" do
    it "should return a new copy of the dataset with no filter applied" do
      ds = FTS.term(comments_count: 5)
      assert_filter ds, {term: {comments_count: 5}}
      assert_filter ds.unfiltered, nil
      assert_filter ds, {term: {comments_count: 5}}
    end
  end
end
