module LibreFrame
  module Core
    # A geometric point.
    class Point
      attr_accessor :x, :y

      def initialize(x, y)
        @x = x
        @y = y
      end

      def +(other)
        case other
        when Point
          Point.new(x + other.x, y + other.y)
        when Numeric
          Point.new(x + other, y + other)
        else
          raise
        end
      end

      def -(other)
        case other
        when Point
          Point.new(x - other.x, y - other.y)
        when Numeric
          Point.new(x - other, y - other)
        else
          raise
        end
      end

      def *(other)
        case other
        when Point
          Point.new(x * other.x, y * other.y)
        when Numeric
          Point.new(x * other, y * other)
        else
          raise
        end
      end

      def to_s
        "(#{x}, #{y})"
      end

      alias inspect to_s
    end
  end
end