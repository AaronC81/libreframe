require_relative '../core/point'

module LibreFrame
  module UI
    # Deals with drag operations on a canvas.
    class DragController
      attr_reader :start_position
      def dragging?; @dragging; end

      # Signals that a drag has reached a point.
      def record_position(x, y)
        pt = Core::Point.new(x, y)
        if @start_point.nil?
          @start_point = pt
        else
          @end_point = pt
        end
      end

      def start_dragging(start_position)
        @dragging = true
        @start_position = start_position
      end

      def current_position
        @start_position + delta
      end

      # Gets the difference between the start and end point of the current drag.
      def delta
        @end_point - @start_point
      rescue
        0
      end

      # Resets this controller after a drag.
      def reset
        @start_point = nil
        @end_point = nil
        @start_position = nil
        @dragging = false
      end
    end
  end
end
