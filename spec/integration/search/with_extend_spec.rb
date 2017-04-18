# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  before do
    store [
      {title: "A", col1: 1, col2: 3},
      {title: "B", col1: 2, col2: 3},
      {title: "C", col1: 3, col2: 2},
      {title: "D", col1: 4, col2: 2},
      {title: "E", col1: 5, col2: 1},
      {title: "F", col1: 6, col2: 1},
    ]
  end

  after { clear_indices }

  describe "#with_extend" do
    it "should add the methods in the block to the dataset" do
      ds1 = TestIndex.sort(:col1)
      ds2 =
        ds1.with_extend do
          def only_twos_and_threes
            bool(should: [{term: {col2: 3}}, {term: {col2: 2}}])
          end
        end

      refute ds1.respond_to?(:only_twos_and_threes)
      assert ds2.respond_to?(:only_twos_and_threes)

      ds3 = ds2.only_twos_and_threes
      assert ds3.respond_to?(:only_twos_and_threes)

      assert_equal %w(A B C D), ds3.map{|doc| doc[:title]}
    end
  end
end
