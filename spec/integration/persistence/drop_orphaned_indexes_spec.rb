# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset, "#drop_orphaned_indexes" do
  def all_index_names
    FTS.
      execute_request(method: :get, path: "/_cat/indices?format=json").
      map{|h| h[:index]}.
      grep(/\Apariah/).
      sort
  end

  after do
    clear_indices
  end

  it "should delete indexes that don't have an alias" do
    assert_equal ['pariah_index_1', 'pariah_index_2'], all_index_names

    FTS.drop_orphaned_indexes

    assert_equal [], all_index_names
  end

  it "should accept a filter argument" do
    assert_equal ['pariah_index_1', 'pariah_index_2'], all_index_names

    FTS.drop_orphaned_indexes(filter: /index_2/)

    assert_equal ['pariah_index_1'], all_index_names
  end

  it "should spare indexes that do have an alias" do
    assert_equal ['pariah_index_1', 'pariah_index_2'], all_index_names

    FTS.execute_request(
      method: :post,
      path: '_aliases',
      body: {actions: [{add: {index: 'pariah_index_2', alias: 'pariah_alias'}}]}
    )

    FTS.drop_orphaned_indexes

    assert_equal ['pariah_index_2'], all_index_names
  end
end
