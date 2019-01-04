require_relative 'element'
require_relative '../core/color'
require_relative '../core/point'

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
          Core::Point.new(absolute_position.x + view.sl(width), absolute_position.y),
          Core::Point.new(absolute_position.x + view.sl(width), absolute_position.y + view.sl(height)),
          Core::Point.new(absolute_position.x, absolute_position.y + view.sl(height))
        ]]
      end

      def cairo_apply_styles(ctx)
        ctx.set_source_rgba(*DEFAULT_BACKGROUND_COLOR)
        ctx.fill_preserve
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