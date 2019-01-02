module LibreFrame
  module Core
    # A geometric point.
    class Point
      attr_accessor :x, :y

      def initialize(x, y)
        @x = x
        @y = y
      end

      # Define the four mathematical boolean operators
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