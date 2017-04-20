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

  describe "#include_explanation" do
    it "should cause the explanation of the match to be returned" do
      ds = @ds.query{{match: {title: "title"}}}.include_explanation

      hits = ds.load.results[:hits][:hits]
      assert_equal 2, hits.length

      hits.each do |hit|
        assert_instance_of Hash, hit[:_explanation]
      end
    end
  end
end
