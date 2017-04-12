# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  describe "#term" do
    it "should return a new copy of the dataset with the term filter applied" do
      ds1 = FTS.term(comments_count: 5)
      assert_filter ds1,
        {term: {comments_count: 5}}

      ds2 = ds1.term(title: "The Joy of Ferrets")
      assert_filter ds2,
        {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}

      ds3 = ds2.term(another_column: "another value")
      assert_filter ds3,
        {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}, {term: {another_column: "another value"}}]}

      # Original datasets left unchanged?
      assert_filter ds1, {term: {comments_count: 5}}

      assert_filter ds2, {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}
    end

    it "should support multiple terms per call" do
      assert_filter \
        FTS.term(comments_count: 5, title: "The Joy of Ferrets"),
        {and: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}
    end
  end
end
