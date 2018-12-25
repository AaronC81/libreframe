module LibreFrame
  module UI
    # A canvas on which designs are displayed.
    class View
      attr_accessor :origin_point, :zoom

      def initialize(origin_point, zoom)
        @origin_point = origin_point
        @zoom = zoom
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