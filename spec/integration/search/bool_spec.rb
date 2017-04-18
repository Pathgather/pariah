# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  before do
    store [
      {title: "Title 1", comments_count: 5, topic: 'a'},
      {title: "Title 2", comments_count: 5, topic: 'b'},
      {title: "Title 3", comments_count: 5, topic: 'a'},
      {title: "Title 4", comments_count: 9, topic: 'b'},
      {title: "Title 5", comments_count: 9, topic: 'a'},
      {title: "Title 6", comments_count: 9, topic: 'b'},
    ]
  end

  after { clear_indices }

  describe "#bool" do
    it "should add a bool filter with the given options to the search" do
      assert_equal ["Title 4", "Title 5", "Title 6"],
        TestIndex.
          bool(must_not: {term: {comments_count: 5}}).
          map{|doc| doc[:title]}.sort
    end

    it "should handle appending bools with must arguments" do
      assert_equal \
        ["Title 1", "Title 3"],
        TestIndex.
          bool(must: {term: {comments_count: 5}}).
          bool(must: {term: {topic: 'a'}}).
          map{|doc| doc[:title]}.sort
    end

    it "should handle appending bools with should arguments" do
      assert_equal \
        ["Title 2", "Title 5"],
        TestIndex.
          bool(should: [{term: {comments_count: 5}}, {term: {topic: 'a'}}]).
          bool(should: [{term: {comments_count: 9}}, {term: {topic: 'b'}}]).
          map{|doc| doc[:title]}.sort
    end

    it "should handle appending bools with must_not arguments" do
      assert_equal \
        ["Title 4", "Title 6"],
        TestIndex.
          bool(must_not: {term: {comments_count: 5}}).
          bool(must_not: {term: {topic: 'a'}}).
          map{|doc| doc[:title]}.sort
    end

    it "should handle appending bools with mixed arguments" do
      assert_equal \
        ["Title 1", "Title 3"],
        TestIndex.
          bool(must: {term: {comments_count: 5}}).
          bool(must_not: {term: {topic: 'b'}}).
          map{|doc| doc[:title]}.sort
    end
  end
end
