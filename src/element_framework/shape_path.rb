require_relative 'element'
require_relative '../core/geometry'
require_relative '../ui/handles/handle'

module LibreFrame
  module ElementFramework
    # A shape path.
    class ShapePath < StyledElement
      # TODO: VERY BAD IMPLEMENTATION WHICH DISCARDS MOST INFO
      attr_accessor :points
      attr_writer :closed
      def closed?; @closed; end

      def initialize
        super
        @points = []
        @closed = true
      end

      # Converts the +CurvePoint+ instances inside +#points+ to absolute 
      # instances of +Point+.
      # @return [Array<Core::Point>] An array of absolute points.
      def absolute_points
        points.map do |cv_pt|
          absolute_position + cv_pt.point * Core::Point.new(width, height)
        end
      end

      def cairo_draw(ctx)        
        # TODO: Implement decent RELATIVE rotation, might want a rotation offset
        # Should translate stuff so midpt is 0,0 then rotate and translate back

        # Iterate over each point
        absolute_points.length.times do |i|
          # Get current point, as a CurvePoint
          current_curve_point = points[i]

          # Find absolute points
          previous_point = absolute_points[i - 1]
          current_point = absolute_points[i]
          next_point = absolute_points[(i + 1) % points.length]

          # Move the point towards the previous and next points
          moved_towards_previous_point = Core::Geometry.change_line_length(previous_point, current_point, -1 * (current_curve_point.corner_radius || 0))
          moved_towards_next_point = Core::Geometry.change_line_length(next_point, current_point, -1 * (current_curve_point.corner_radius || 0))

          # Draw a curve for this point
          # TODO: The rounding isn't "intense" enough for some corners
          #       Sketch probably transforms the radius somehow, maybe based on
          #       what the size of the corner round will be
          ctx.line_to(moved_towards_previous_point.x, moved_towards_previous_point.y)
          #ctx.line_to(moved_towards_next_point.x, moved_towards_next_point.y)
          ctx.curve_to(
            current_point.x,
            current_point.y,
            moved_towards_next_point.x,
            moved_towards_next_point.y,
            moved_towards_next_point.x,
            moved_towards_next_point.y
          )

          view.debug_points << moved_towards_previous_point
          view.debug_points << current_point
          view.debug_points << moved_towards_next_point
        end
        ctx.close_path if closed?  

        cairo_draw_styles(ctx)
        cairo_draw_children(ctx)
      end

      def handles
        # TODO: When stuff moves, it needs to resize the contained element to
        # keep everything within {1, 1}.
        super + points.map do |point|
          UI::Handles::Handle.new(self,
            UI::Property.new(
              'Point',
              ->{ absolute_position + point.point * Core::Point.new(width, height) },
              ->x{ point.point = (x - absolute_position) / Core::Point.new(width, height) } # TODO: Undo rotation
            )
          )
        end
      end

      def from_sketch_json_hash(hash, loader)
        super

        @points = hash['points'].map { |p| loader.dispatch(p) }
        if @points.select! { |p| !p.point.nil? && !p.curve_from.nil? && !p.curve_to.nil? } != nil
          loader.log "a ShapePath CurvePoints contained nil"
        end

        @closed = hash['isClosed']
      end

      # TODO: Cairo has a method for hit detection along a path which could be
      # used to make this MUCH better, though it would require a redraw on click
      # most likely (expensive) unless we gave elements a method to just plot
      # their path and not actually apply any style.
      # https://cairographics.org/manual/cairo-cairo-t.html#cairo-stroke-extents
      def contains_position?(point)
        translated_position = absolute_position

        # TODO: Sizing ignores zoom
        # TODO: Disgustingly long line
        point.x >= translated_position.x && point.x <= translated_position.x + width && point.y >= translated_position.y && point.y <= translated_position.y + height
      end

      # Re-scales this ShapePath so that, for each element of #points,
      # CurvePoint#point is in the range {0, 1}. This involves resizing and 
      # moving the ShapePath.
      def reproportion
        # Find new position and size
        new_position = Core::Point.new(
          absolute_points.map(&:x).min,
          absolute_points.map(&:y).min
        )
        new_width = absolute_points.map(&:x).max - new_position.x
        new_height = absolute_points.map(&:y).max - new_position.y

        # Translate points back into relative using new width and height
        points.zip(absolute_points).map do |curve_point, point|
          # TODO: Does not consider curveFrom/to (fix when those actually become used)
          curve_point.point = Core::Point.new(
            (point.x - new_position.x) / new_width,
            (point.y - new_position.y) / new_height
          )
        end

        self.absolute_position = new_position
        @width = new_width
        @height = new_height
      end
    end
  end
end