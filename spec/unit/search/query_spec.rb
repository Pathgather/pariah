# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  describe "#query" do
    def assert_query(ds, expected)
      actual = ds.to_query[:query][:bool][:must]

      if expected.nil?
        assert_nil actual
      else
        assert_equal expected, actual
      end
    end

    it "should return a new copy of the dataset with the filter applied" do
      ds1 =
        FTS.query { |q| { function_score: { query: q, boost: 5 } } }

      assert_query ds1,
        {
          function_score: {
            query: {match_all: {}},
            boost: 5,
          }
        }

      ds2 =
        ds1.query { |q| { function_score: { query: q, boost: 10 } } }

      assert_query ds2,
        {
          function_score: {
            query: {
              function_score: {
                query: {match_all: {}},
                boost: 5,
              }
            },
            boost: 10,
          }
        }

      # Original datasets left unchanged?
      assert_query ds1,
        {
          function_score: {
            query: {match_all: {}},
            boost: 5,
          }
        }
    end
  end
end
