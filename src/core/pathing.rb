module LibreFrame
  module Core
    module Pathing
      # Given a Cairo context and a point path, plots the point path onto the
      # Cairo context.
      # @param ctx [Cairo::Context] The Cairo context to use. The current path
      #   is destroyed.
      # @param path [Array<Core::Point>] The path to follow.
      def self.cairo_plot(ctx, path)
        ctx.new_path

        # Don't do anything if path is empty
        return if path.empty?

        # Move to the starting location and trace path around
        ctx.move_to(*path.first)
        path[1..-1].each do |point|
          ctx.line_to(*point)
        end
        ctx.line_to(*path.first)

        nil
      end
    end
  end
end