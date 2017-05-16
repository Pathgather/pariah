# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#reindex" do
  after { clear_indices }

  module ItReindexesProperly
    def self.included(base)
      base.class_eval do
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

          assert_equal true, result
          assert_equal ["Title 1", "Title 2"], TestIndex.map{|r| r[:title]}.sort

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

          indexes =
            FTS.send(
              :execute_request,
              method: :get,
              path: '_cat/indices/pariah_index_1*?format=json',
            )

          names = indexes.map{|i| i[:index]}

          assert_equal [new_index_name], names
        end

        describe "when the block throws an error" do
          def get_aliases
            FTS.send(
              :execute_request,
              method: :get,
              path: ['pariah_index_1', '_aliases'],
              allowed_codes: [200, 404],
            )
          end

          def get_records
            TestIndex.all.sort_by{|r| r[:title]}
          rescue Pariah::Error => e
            if e.message =~ /index_not_found_exception/
              :index_not_found
            else
              raise e
            end
          end

          it "should recover properly" do
            aliases_before = get_aliases
            records_before = get_records

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

            aliases_after = get_aliases
            records_after = get_records

            assert_equal aliases_before, aliases_after
            assert_equal records_before, records_after
          end
        end
      end
    end
  end

  describe "when the index hasn't been created yet" do
    include ItReindexesProperly

    before do
      TestIndex.drop_index
    end
  end

  describe "when there is an index with the given name already in place" do
    include ItReindexesProperly

    before do
      store [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
        {title: "Title 3", comments_count: 5},
      ]
    end
  end

  describe "where there is an alias with the given name already in place" do
    include ItReindexesProperly

    before do
      TestIndex.reindex do |ds|
        ds.type(:pariah_type_1).upsert([
          {title: "Title 1", comments_count: 5},
          {title: "Title 2", comments_count: 9},
        ])
      end
    end
  end
end
