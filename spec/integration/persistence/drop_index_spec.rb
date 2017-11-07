# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  def all_index_names
    FTS.
      execute_request(method: :get, path: "/_cat/indices?format=json").
      map{|h| h[:index]}.
      grep(/\Apariah/).
      sort
  end

  after { clear_indices }

  describe "#drop_index" do
    it "should drop an index" do
      assert_equal ['pariah_index_1', 'pariah_index_2'], all_index_names

      FTS[:pariah_index_2].drop_index

      assert_equal ['pariah_index_1'], all_index_names
    end
  end

  describe "#drop_index?" do
    it "should recover from an error that prevented the index from being deleted" do
      assert_equal ['pariah_index_1', 'pariah_index_2'], all_index_names

      $break = true

      assert_equal false, FTS[:pariah_index_3].drop_index?

      assert_equal ['pariah_index_1', 'pariah_index_2'], all_index_names
    end
  end
end
