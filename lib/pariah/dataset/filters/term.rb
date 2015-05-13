module Pariah
  module Filters
    class Term
      def initialize(condition)
        @condition = condition
      end

      def to_query
        {term: @condition}
      end
    end
  end
end
