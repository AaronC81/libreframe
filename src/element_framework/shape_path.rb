require_relative 'element'
require_relative '../core/geometry'
require_relative '../ui/handles/handle'

module LibreFrame
  module ElementFramework
    # A shape path.
    class ShapePath < StyledElement
      attr_accessor :points, :boolean_operation
      attr_writer :closed
      def closed?; @closed; end

      def initialize
        super
        @points = []
        @closed = true
      end

      # Given a point inside this +ShapePath+ with coordinates between 0 and 1,
      # such as a +CurvePoint+, converts it to an absolute point.
      # @param point [Core::Point] The point to convert.
      # @return [Core::Point] The converted point.
      def make_absolute(point)
        absolute_position + point * Core::Point.new(width, height)
      end

      # Converts the +CurvePoint+ instances inside +#points+ to absolute 
      # instances of +Point+.
      # Note that these points are NOT rotated. Rotation is handled by Cairo,
      # except for handles.
      # @return [Array<Core::Point>] An array of absolute points.
      def absolute_points
        points.map do |cv_pt|
          make_absolute(cv_pt.point)
        end
      end

      def cairo_draw_styles(ctx)
        # TODO: Does this handle deep nesting properly?
        super
        parent.cairo_draw_styles(ctx) if parent.is_a?(ShapeGroup)
      end
      
      def drawing_paths
        # TODO: Doesn't support curves yet
        
        drawing_points = []
        absolute_points.length.times do |i|
          # Get current point, as a CurvePoint
          previous_curve_point = points[i - 1]
          current_curve_point = points[i]
          next_curve_point = points[(i + 1) % points.length]

          # Find absolute points, also rotating them
          previous_point = absolute_points[i - 1]
            .rotate_around_point(total_rotation, center)
          current_point = absolute_points[i]
            .rotate_around_point(total_rotation, center)
          next_point = absolute_points[(i + 1) % points.length]
            .rotate_around_point(total_rotation, center)

          # Copy the current point but moved towards the previous/next ones, in
          # order to create points for a rounded corner Bezier curve
          moved_towards_previous_point = Core::Geometry.change_line_length(
            previous_point, current_point,
            -1 * (current_curve_point.corner_radius || 0)
          )
          moved_towards_next_point = Core::Geometry.change_line_length(
            next_point, current_point,
            -1 * (current_curve_point.corner_radius || 0)
          )

          # Use Bezier curve to work out corner rounding
          points = Core::Geometry.bezier_to_points(
            moved_towards_previous_point,
            current_point,
            moved_towards_next_point,
            moved_towards_next_point
          )
          drawing_points.push(*points)
        end

        [drawing_points]
      end

      def handles
        super + points.map do |curve_point|
          UI::Handles::Handle.new(self,
            UI::Property.new(
              'Point',
              ->{ (
                absolute_position + curve_point.point * Core::Point.new(width, height)
              ).rotate_around_point(total_rotation, center) },
              # TODO: Need to "pin" the rest of the shape so it doesn't move around strangely
              ->x{ curve_point.point = ((x.rotate_around_point(-total_rotation, center) - absolute_position) / Core::Point.new(width, height)) } # TODO: Undo rotation
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
        @boolean_operation = hash['booleanOperation'].to_i
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