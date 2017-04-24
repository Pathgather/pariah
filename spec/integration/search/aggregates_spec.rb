# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#aggs" do
    before do
      @topics = ["sit", "blanditiis", "omnis", "est", "nam"]

      store 100.times.map {
        {
          topic: @topics.sample,
        }
      }
    end

    it "specifies a list of fields to aggregate on" do
      ds = FTS[:pariah_index_1].aggs(:_type, :topic)
      results = ds.aggregations

      categories = results[:topic][:buckets]

      assert_equal \
        ["sit", "blanditiis", "omnis", "est", "nam"].sort,
        categories.map{|c| c[:key]}.sort

      assert_equal 100, categories.inject(0){|total, c| total + c[:doc_count]}
    end
  end
end
