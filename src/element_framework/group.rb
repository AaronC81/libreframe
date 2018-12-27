require_relative 'element'

module LibreFrame
  module ElementFramework
    # A group of other elements.
    class Group < StyledElement
      def initialize
        super
      end

      def cairo_draw(ctx)
        cairo_draw_children(ctx)
      end
    end
  end
end