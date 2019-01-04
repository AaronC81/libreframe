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

      def drawing_paths
        [[
          absolute_position,
          Point.new(absolute_position.x + view.sl(width), absolute_position.y),
          Point.new(absolute_position.x + view.sl(width), absolute_position.y + view.sl(height)),
          Point.new(absolute_position.x, absolute_position.y + view.sl(height))
        ]]
      end

      def cairo_draw(ctx)        
        abs_pos = absolute_position
        ctx.rectangle(abs_pos.x, abs_pos.y, view.sl(width), view.sl(height))

        ctx.set_source_rgba(*DEFAULT_BACKGROUND_COLOR)
        ctx.fill_preserve

        cairo_draw_children(ctx)
      end
    end
  end
end