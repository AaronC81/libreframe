require_relative 'styled_element'
require_relative 'shape_path'

module LibreFrame
  module ElementFramework
    # Turns out, rectangles can be emulated exactly with shape paths, and
    # they can also be modified just like a shape path so it makes more sense
    # to treat them as such.
    class Rectangle < ShapePath; end

    <<-HERE
    # An old-style rectangle.
    class OldRectangle < StyledElement
      def initialize
        super
      end

      def cairo_draw(ctx, view)
        translated_point = view.tp(position) + offset #relative_to.position

        ctx.rectangle(translated_point.x, translated_point.y, view.sl(width), view.sl(height))

        cairo_draw_styles(ctx, view)
        cairo_draw_children(ctx, view)
      end

      def contains_position?(click_point, view)
        o = view.tp(position) + offset
        w = view.sl(width)
        h = view.sl(height)

        p click_point

        click_point.x >= o.x && click_point.y >= o.y && click_point.x <= o.x + w && click_point.y <= o.y + h
      end
    end
    HERE
  end
end