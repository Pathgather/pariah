# frozen_string_literal: true

module Pariah
  class Dataset
    class Bool
      COMPONENTS = [:must, :filter, :should, :must_not].freeze

      attr_reader(*COMPONENTS)

      def initialize(must: nil, filter: nil, should: nil, must_not: nil)
        @must     = Array(must).compact
        @filter   = Array(filter).compact
        @should   = Array(should).compact
        @must_not = Array(must_not).compact
      end

      def merge(other)
        self.class.new(
          must:     must     + other.must,
          filter:   filter   + other.filter,
          should:   should   + other.should,
          must_not: must_not + other.must_not,
        )
      end

      def to_hash
        hash = {}

        COMPONENTS.each do |component|
          value = send(component)
          hash[component] = value unless value.empty?
        end

        hash
      end

      def to_json(*args)
        to_hash.to_json(*args)
      end
    end
  end
end
