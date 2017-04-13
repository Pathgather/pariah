# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  before do
    store [
      {title: "Title 1", comments_count: 24, other_a: 'string1', other_b: 'string3'},
      {title: "Title 2", comments_count: 67, other_a: 'string2', other_b: 'string4'},
    ]

    @ds = FTS[:pariah_index_1]
  end

  describe "#fields" do
    it "should select the fields to be returned" do
      datasets = [
        @ds.fields(:title, :comments_count),
        @ds.append_fields(:title, :comments_count),
        @ds.fields(:title).append_fields(:comments_count),
      ]

      datasets.each do |dataset|
        assert_equal \
          [
            {title: "Title 1", comments_count: 24},
            {title: "Title 2", comments_count: 67},
          ],
          dataset.all.sort_by{|r| r[:comments_count]}
      end
    end

    it "with wildcards should include matching fields" do
      datasets = [
        @ds.fields(:title, 'other_*'),
        @ds.append_fields(:title, 'other_*'),
        @ds.fields(:title).append_fields('other_*'),
      ]

      datasets.each do |dataset|
        assert_equal \
          [
            {title: "Title 1", other_a: 'string1', other_b: 'string3'},
            {title: "Title 2", other_a: 'string2', other_b: 'string4'},
          ],
          dataset.all.sort_by{|r| r[:title]}
      end
    end
  end

  describe "#exclude_fields" do
    it "should exclude the given fields" do
      datasets = [
        @ds.exclude_fields(:title, :other_a, :other_b),
      ]

      datasets.each do |dataset|
        results = dataset.all

        assert_equal [24, 67], results.map{|r| r[:comments_count]}.sort

        results.each do |r|
          keys = r.keys
          refute_includes keys, :title
          refute_includes keys, :other_a
          refute_includes keys, :other_b
        end
      end
    end

    it "with wildcards should exclude matching fields" do
      results = @ds.exclude_fields(:title, 'other_*').all
      assert_equal [24, 67], results.map{|r| r[:comments_count]}.sort

      results.each do |r|
        keys = r.keys
        refute_includes keys, :title
        refute_includes keys, :other_a
        refute_includes keys, :other_b
      end
    end
  end
end
