require_relative 'stroke'

module LibreFrame
  module Styling
    # An abstract class specifying a method of stroking.
    # TODO: Remove this and just use stroke
    class SolidStroke < Stroke
      attr_accessor :color

      def initialize(color)
        super()

        @color = color
      end

      def cairo_draw(ctx)
        ctx.set_source_rgb(*color)
        ctx.stroke_preserve
      end
    end
  end
end