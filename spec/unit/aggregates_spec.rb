# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#aggregate" do
  it "specifies a list of fields to aggregate on" do
    ds = FTS[:pariah_test_default].aggregates(:a, :b)

    assert_equal(
      {a: {terms: {field: :a}}, b: {terms: {field: :b}}},
      ds.to_query[:aggs],
    )
  end
end
