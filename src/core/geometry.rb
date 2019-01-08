require 'bezier'

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

      # Calculates the distance between two points.
      # @param a [Point] The first point.
      # @param b [Point] The second point.
      # @return [Numeric] The distance between the two points.
      def self.distance(a, b)
        Math.sqrt((b.x - a.x)**2 + (b.y - a.y)**2)
      end

      # Converts a Bezier curve into a series of points which roughly trace the
      # same curve.
      # @param start [Point] The start of the Bezier curve.
      # @param control_1 [Point] The first control point of the Bezier curve.
      # @param control_2 [Point] The second control point of the Bezier curve.
      # @param finish [Point] The end control point of the Bezier curve.
      # @param resolution_factor [Numeric] Used to control the number of points
      #   generated. A greater resolution results in more points, which will
      #   look better but requires more time to draw. Note that resolution is
      #   controlled somewhat automatically based on the length of the curve,
      # but this will act as a multiplier on that.
      # @return An array of points representing the Bezier curve.
      def self.bezier_to_points(start, control_1, control_2, finish, resolution_factor=1)
        # Work out the total distance between points, for resolution calculation
        total_distance = [
          Geometry.distance(start, control_1),
          Geometry.distance(control_1, control_2),
          Geometry.distance(control_2, finish)
        ].sum        

        # Convert Core::Point to Bezier::Point
        start = Bezier::Point.new(*start)
        control_1 = Bezier::Point.new(*control_1)
        control_2 = Bezier::Point.new(*control_2)
        finish = Bezier::Point.new(*finish)

        # Create curve instance
        bezier = Bezier::Bezier.new(start, control_1, control_2, finish)

        resolution = total_distance # TODO: Multiply by something?
        resolution *= resolution_factor

        # Work out time step based on resolution
        time_step = 1 / resolution
        p time_step
        current_time = 0

        # Calculate each point
        points = []
        while current_time < 1
          points << bezier.point_from_t(current_time)
          current_time += time_step
        end

        points
      end
    end
  end
end
