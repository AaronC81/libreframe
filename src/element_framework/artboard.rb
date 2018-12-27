require_relative 'element'
require_relative '../core/color'

module LibreFrame
  module ElementFramework
    # An artboard which contains other elements.
    class Artboard < StyledElement
      DEFAULT_BACKGROUND_COLOR = Core::Color.new(1, 1, 1, 1)

      def initialize
        super
      end

      def cairo_draw(ctx)        
        abs_pos = absolute_position
        ctx.rectangle(abs_pos.x, abs_pos.y, view.sl(width), view.sl(height))

        if fills.empty?
          ctx.set_source_rgba(*DEFAULT_BACKGROUND_COLOR.to_cairo)
          ctx.fill_preserve
        else
          cairo_draw_styles(ctx)
        end

        cairo_draw_children(ctx)
      end
    end
  end
end