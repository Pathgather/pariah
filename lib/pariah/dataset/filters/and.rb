module Pariah
  module Filters
    class And
      attr_reader :args

      def initialize(*args)
        @args = args
      end

      def to_query
        {and: @args.map(&:to_query)}
      end
    end
  end
end
