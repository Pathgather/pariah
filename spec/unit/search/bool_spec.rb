# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  describe "#bool" do
    it "should append a new boolean condition from the given conditions" do
      assert_filter FTS.bool(must_not: {term: {comments_count: 5}}),
        {bool: {must_not: [{term: {comments_count: 5}}]}}
    end
  end
end
