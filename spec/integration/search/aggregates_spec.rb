# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  before do
    @topics = ["sit", "blanditiis", "omnis", "est", "nam"]

    store 100.times.map {
      {
        topic: @topics.sample,
      }
    }
  end

  describe "#aggs" do
    it "specifies a list of fields to aggregate on" do
      ds = FTS[:pariah_index_1].aggs(:_type, :topic)
      results = ds.aggregations

      categories = results[:topic][:buckets]

      assert_equal \
        @topics.sort,
        categories.map{|c| c[:key]}.sort

      assert_equal 100, categories.inject(0){|total, c| total + c[:doc_count]}
    end
  end

  describe "#post_filter" do
    it "applies a post filter that won't affect the aggregates" do
      ds =
        FTS[:pariah_index_1].
          aggs(:topic).
          post_filter(term: {topic: "sit"}).
          load

      assert_equal 100,
        ds.aggregations[:topic][:buckets].
        inject(0){|total, c| total + c[:doc_count]}

      ds.all.each { |doc| assert_equal 'sit', doc[:topic] }
    end
  end
end
