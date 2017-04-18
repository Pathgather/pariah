# frozen_string_literal: true

require 'spec_helper'

describe Pariah do
  describe "#bool" do
    it "should be a handy shortcut to create a Bool object" do
      b = Pariah.bool(should: {term: {col1: 4}})
      assert_instance_of Pariah::Dataset::Bool, b
      assert_equal [{term: {col1: 4}}], b.should
    end
  end
end
