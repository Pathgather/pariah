# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  describe "#filter" do
    it "should return a new copy of the dataset with the filter applied" do
      ds1 = FTS.filter(term: {comments_count: 5})
      assert_filter ds1,
        {bool: {must: [{term: {comments_count: 5}}]}}

      ds2 = ds1.filter(term: {title: "The Joy of Ferrets"})
      assert_filter ds2,
        {bool: {must: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}}

      ds3 = ds2.filter(term: {another_column: "another value"})
      assert_filter ds3,
        {bool: {must: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}, {term: {another_column: "another value"}}]}}

      # Original datasets left unchanged?
      assert_filter ds1, {bool: {must: [{term: {comments_count: 5}}]}}

      assert_filter ds2, {bool: {must: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}}
    end

    it "should support multiple terms per call" do
      assert_filter \
        FTS.filter({term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}),
        {bool: {must: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}]}}
    end

    it "should chain items together correctly when passed multiple terms" do
      assert_filter \
        FTS.
          filter(term: {comments_count: 5}).filter({term: {title: "The Joy of Ferrets"}}, {term: {another_column: "another value"}}),
          {bool: {must: [{term: {comments_count: 5}}, {term: {title: "The Joy of Ferrets"}}, {term: {another_column: "another value"}}]}}
    end
  end
end
