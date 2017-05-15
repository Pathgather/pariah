# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#reindex" do
  before do
    store [
      {title: "Title 1", comments_count: 5},
      {title: "Title 2", comments_count: 9},
      {title: "Title 3", comments_count: 5},
    ]
  end

  after { clear_indices }

  it "should create a new timestamped index and alias it to the given name" do
    new_index_name = nil

    result =
      TestIndex.reindex do |ds|
        new_index_name = ds.send(:single_index)

        ds.type(:pariah_type_1).upsert([
          {title: "Title 1", comments_count: 5},
          {title: "Title 2", comments_count: 9},
        ])
      end

    assert_equal ["Title 1", "Title 2"], TestIndex.map{|r| r[:title]}.sort
    assert_equal true, result

    assert_match(/\Apariah_index_1-\d{10,12}\.\d+\z/, new_index_name)

    aliases =
      FTS.send(
        :execute_request,
        method: :get,
        path: [new_index_name, '_aliases']
      )

    assert_equal(
      {new_index_name.to_sym => {aliases: {pariah_index_1: {}}}},
      aliases
    )
  end

  it "should also work if the index being replaced is an alias" do
    new_index_name = nil

    TestIndex.reindex do |ds|
      ds.type(:pariah_type_1).upsert([
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
      ])
    end

    TestIndex.reindex do |ds|
      new_index_name = ds.send(:single_index)

      ds.type(:pariah_type_1).upsert([
        {title: "Title 3", comments_count: 5},
        {title: "Title 4", comments_count: 9},
      ])
    end

    assert_equal ["Title 3", "Title 4"], TestIndex.map{|r| r[:title]}.sort

    aliases =
      FTS.send(
        :execute_request,
        method: :get,
        path: [new_index_name, '_aliases']
      )

    assert_equal(
      {new_index_name.to_sym => {aliases: {pariah_index_1: {}}}},
      aliases
    )
  end

  describe "when raising an error" do
    it "should destroy the temporary index and leave the original index intact" do
      error = assert_raises(RuntimeError) do
        TestIndex.reindex do |ds|
          ds.type(:pariah_type_1).upsert([
            {title: "Title 4", comments_count: 5},
            {title: "Title 5", comments_count: 9},
          ])

          raise "Hell!"
        end
      end

      assert_equal "Hell!", error.message
      assert_equal ["Title 1", "Title 2", "Title 3"], TestIndex.map{|r| r[:title]}.sort

      aliases =
        FTS.send(
          :execute_request,
          method: :get,
          path: ['pariah_index_1', '_aliases']
        )

      assert_equal({pariah_index_1: {aliases: {}}}, aliases)
    end

    describe "when the target index is already an alias" do
      it "should behave the same way" do
        index_alias_name = nil
        TestIndex.reindex do |ds|
          index_alias_name = ds.send(:single_index)

          ds.type(:pariah_type_1).upsert([
            {title: "Title 1", comments_count: 5},
            {title: "Title 2", comments_count: 9},
          ])
        end

        error = assert_raises(RuntimeError) do
          TestIndex.reindex do |ds|
            ds.type(:pariah_type_1).upsert([
              {title: "Title 4", comments_count: 5},
              {title: "Title 5", comments_count: 9},
            ])

            raise "Hell!"
          end
        end

        assert_equal "Hell!", error.message
        assert_equal ["Title 1", "Title 2"], TestIndex.map{|r| r[:title]}.sort

        aliases =
          FTS.send(
            :execute_request,
            method: :get,
            path: ['pariah_index_1', '_aliases']
          )

        assert_equal({index_alias_name.to_sym => {aliases: {pariah_index_1: {}}}}, aliases)
      end
    end
  end
end
