require_relative 'element'

module LibreFrame
  module ElementFramework
    # A group of other elements.
    class Group < Element
      attr_accessor :fills, :strokes

      def initialize
        super
      end

      def cairo_draw(ctx, view)
        cairo_draw_children(ctx, view)
      end
    end
  end
end