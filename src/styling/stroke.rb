module LibreFrame
  module Styling
    # An abstract class specifying a method of stroking.
    # TODO: Support inner/outer/middle
    class Stroke
      attr_writer :enabled
      def enabled?; @enabled; end

      def initialize
        @enabled = true
      end

      # Executes this stroke onto a Gtk3 Cairo context, given that the shape
      # has already been specified.  This abstract implementation simply
      # throws an exception, so subclasses MUST NOT invoke super in their
      # implementations. Implementations should preserve the shape.
      def cairo_draw(context)
        raise 'this stroke cannot be drawn (tried to draw abstract Stroke)'
      end
    end
  end
end