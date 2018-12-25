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

        Core::Point.new(e.x + delta_x * delta, e.y + delta_y * delta)
      end
    end
  end
end
