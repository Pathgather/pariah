require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  before do
    store_bodies [
      {title: "Title 1", comments_count: 24, other_a: 'string1', other_b: 'string3'},
      {title: "Title 2", comments_count: 67, other_a: 'string2', other_b: 'string4'},
    ]

    @ds = FTS[:pariah_test_default]
  end

  context "#fields" do
    it "should select the fields to be returned" do
      datasets = [
        @ds.fields(:title, :comments_count),
        @ds.append_fields(:title, :comments_count),
        @ds.field(:title).append_field(:comments_count),
      ]

      datasets.each do |dataset|
        dataset.all.sort_by{|r| r[:comments_count]}.should == [
          {title: "Title 1", comments_count: 24},
          {title: "Title 2", comments_count: 67},
        ]
      end
    end

    it "with wildcards should include matching fields" do
      datasets = [
        @ds.fields(:title, 'other_*'),
        @ds.append_fields(:title, 'other_*'),
        @ds.field(:title).append_field('other_*'),
      ]

      datasets.each do |dataset|
        dataset.all.sort_by{|r| r[:title]}.should == [
          {title: "Title 1", other_a: 'string1', other_b: 'string3'},
          {title: "Title 2", other_a: 'string2', other_b: 'string4'},
        ]
      end
    end
  end

  context "#exclude_fields" do
    it "should exclude the given fields" do
      datasets = [
        @ds.exclude_fields(:title, :other_a, :other_b),
        @ds.exclude_field(:title).append_exclude_fields(:other_a, :other_b),
      ]

      datasets.each do |dataset|
        results = dataset.all

        results.map{|r| r[:comments_count]}.sort.should == [24, 67]

        results.each do |r|
          r.keys.include?(:title).should be false
          r.keys.include?(:other_a).should be false
          r.keys.include?(:other_b).should be false
        end
      end
    end

    it "with wildcards should exclude matching fields" do
      results = @ds.exclude_fields(:title, 'other_*').all
      results.map{|r| r[:comments_count]}.sort.should == [24, 67]

      results.each do |r|
        r.keys.include?(:title).should be false
        r.keys.include?(:other_a).should be false
        r.keys.include?(:other_b).should be false
      end
    end
  end
end
