require 'spec_helper'

describe Pariah::Dataset, "#aggregate" do
  def teardown
    super
    clear_indices
  end

  it "specifies a list of fields to aggregate on" do
    ds = FTS[:pariah_test_default].aggregate(:a, :b)

    assert_equal(
      {a: {terms: {field: :a}}, b: {terms: {field: :b}}},
      ds.to_query[:body][:aggs],
    )
  end
end
