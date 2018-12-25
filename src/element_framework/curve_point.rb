require_relative 'element'

module LibreFrame
  module ElementFramework
    # A point on a shape path's curve. This is not an element per se, but may
    # be created by a Loader like one.
    # TODO: When curveFrom/curveTo is true, it does a "CUBIC SPLINE" between
    # those points.
    class CurvePoint
      attr_accessor :curve_from, :curve_to, :point, :corner_radius

      def initialize
        # TODO: Discards much info
        @curve_from = nil
        @curve_to = nil
        @point = nil
        @corner_radius = nil
      end

      def from_sketch_json_hash(hash, loader)
        @curve_from = loader.string_to_point(hash['curveFrom'])
        @curve_to = loader.string_to_point(hash['curveTo'])
        @point = loader.string_to_point(hash['point'])
        @corner_radius = loader.string_to_point(hash['cornerRadius'])
      end
    end
  end
end
