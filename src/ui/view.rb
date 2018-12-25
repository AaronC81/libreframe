module LibreFrame
  module UI
    # A canvas on which designs are displayed.
    class View
      attr_accessor :origin_point, :zoom, :debug_points

      attr_writer :debug
      def debug?; @debug; end

      def initialize(origin_point, zoom)
        @origin_point = origin_point
        @zoom = zoom
        @debug_points = []
        @debug = false
      end

      def translate_point(point)
        # TODO: HOW TO IMPLEMENT ZOOM?
        origin_point + point
      end

      def scale_length(length)
         # TODO: HOW TO IMPLEMENT ZOOM?
        length
      end

      alias tp translate_point
      alias sl scale_length
    end
  end
end