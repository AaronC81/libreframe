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

      # Rotates a point a number of radians around a different point.
      # @param angle [Float] The radians to rotate.
      # @param point [Point] The point around which to rotate.
      # @return [Point] A rotated point.
      def rotate_around_point(angle, point)
        Point.new(x - point.x, y - point.y).rotate_around_origin(angle) + point
      end

      # Rotates a point a number of radians around the origin.
      # @param angle [Float] The radians to rotate.
      # @return [Point] A rotated point.
      def rotate_around_origin(angle)
        sin_of_angle = Math.sin(angle)
        cos_of_angle = Math.cos(angle)

        Point.new(
          x * cos_of_angle - y * sin_of_angle,
          x * sin_of_angle + y * cos_of_angle
        )
      end

      # Converts this path to an array.
      # @return [Array<Float>] An array in the form [x, y].
      def to_a
        [x, y]
      end

      def to_s
        "(#{x}, #{y})"
      end
      alias inspect to_s
    end
  end
end