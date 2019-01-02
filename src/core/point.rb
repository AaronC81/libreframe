module LibreFrame
  module Core
    # A geometric point.
    class Point
      attr_accessor :x, :y

      # Creates a new +Point+.
      # @param x [Numeric] The x coordinate of this point.
      # @param y [Numeric] The y coordinate of this point.
      def initialize(x, y)
        @x = x
        @y = y
      end

      # @!method +(other)
      #   Add another point, or a scalar, to this point.
      # @!method -(other)
      #   Subtract another point, or a scalar, from this point.
      # @!method *(other)
      #   Multiply another point, or a scalar, with this point.
      # @!method /(other)
      #   Divide another point, or a scalar, with this point.
      [:+, :-, :*, :/].each do |op|
        define_method(op) do |other|
          case other
          when Point
            Point.new(x.send(op, other.x), y.send(op, other.y))
          when Numeric
            Point.new(x.send(op, other), y.send(op, other))
          else
            raise
          end
        end
      end

      def to_s
        "(#{x}, #{y})"
      end
      alias inspect to_s
    end
  end
end