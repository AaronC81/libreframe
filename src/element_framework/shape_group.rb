require_relative 'element'

module LibreFrame
  module ElementFramework
    # A group of other elements which are drawn on the same "plane" using
    # boolean operations. This enables the shapes to blend together.
    class ShapeGroup < StyledElement
      def initialize
        super
      end

      def cairo_draw(ctx)
        cairo_draw_children(ctx)
      end
    end
  end
end