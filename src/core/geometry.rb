module LibreFrame
  module Core
    # Contains methods for performing basic geometric operations.
    module Geometry
      # Given the start and end point of a line, returns the new end point if
      # the line's length is altered by a particular delta.
      # The point 'e' is the one modified.
      def self.change_line_length(s, e, delta)
        divisor = Math.sqrt((e.x - s.x)**2 + (e.y - s.y)**2)

        delta_x = (e.x - s.x) / divisor
        delta_y = (e.y - s.y) / divisor

        Point.new(e.x + delta_x * delta, e.y + delta_y * delta)
      end

      # Calculates the intersection of the perpendiculars of two lines.
      # The lines are specified by two points each:
      # - The pivot point, which is where the line is "rotated" around to obtain
      #   the perpendicular.
      # - The guide point, which is used to calculate the gradient alongside the
      #   pivot point.
      def self.perpendicular_intersects(first_pivot, first_guide, second_pivot, second_guide)
        # Calculate gradients
        first_grad = (first_pivot.y - first_guide.y)/(first_pivot.x - first_guide.x)
        second_grad = (second_pivot.y - second_guide.y)/(second_pivot.x - second_guide.x)

        # Calculate perpendicular gradients
        first_perp_grad = -1 / first_grad
        second_perp_grad = -1 / second_grad

        # Find y intersects
        first_c = -first_perp_grad * first_pivot.x + first_pivot.y
        second_c = -second_perp_grad * second_pivot.x + second_pivot.y

        # Find intersect x and y
        isct_x = (first_c - second_c) / (second_perp_grad - first_perp_grad)
        isct_y = second_c + second_perp_grad * isct_x

        Point.new(isct_x, isct_y)
      end
    end
  end
end
