module Pariah
  module Filters
    class And
      def initialize(left, right)
        @left  = left
        @right = right
      end

      def to_query
        {and: [@left.to_query, @right.to_query]}
      end
    end
  end
end
