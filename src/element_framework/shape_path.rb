require_relative 'element'
require_relative '../core/geometry'

module LibreFrame
  module ElementFramework
    # A shape path.
    # TODO: Implement corner radius
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

      def cairo_draw(ctx, view)        
        # TODO: Implement decent RELATIVE rotation, might want a rotation offset
        # Should translate stuff so midpt is 0,0 then rotate and translate back
        translated_origin_point = view.tp(position) + offset

        # Iterate over each point
        points.length.times do |i|
          # Find points
          previous_point = points[i - 1]
          current_point = points[i]
          next_point = points[(i + 1) % points.length]

          # Translate each point from relative ratio to actual point
          translated_current_point = translated_origin_point + current_point.point * Core::Point.new(width, height)
          translated_previous_point = translated_origin_point + previous_point.point * Core::Point.new(width, height)
          translated_next_point = translated_origin_point + next_point.point * Core::Point.new(width, height)

          # Move the point towards the previous and next points
          moved_towards_previous_point = Core::Geometry.change_line_length(translated_previous_point, translated_current_point, -1 * (current_point.corner_radius || 0))
          moved_towards_next_point = Core::Geometry.change_line_length(translated_next_point, translated_current_point, -1 * (current_point.corner_radius || 0))

          # Draw a "curve" for this point
          ctx.line_to(moved_towards_previous_point.x, moved_towards_previous_point.y)
          ctx.line_to(moved_towards_next_point.x, moved_towards_next_point.y)

          view.debug_points << moved_towards_previous_point
          view.debug_points << translated_current_point
          view.debug_points << moved_towards_next_point
        end
        ctx.close_path if closed?  

        cairo_draw_styles(ctx, view)

        cairo_draw_children(ctx, view)
      end

      def from_sketch_json_hash(hash, loader)
        super

        @points = hash['points'].map { |p| loader.dispatch(p) }
        if @points.select! { |p| !p.point.nil? && !p.curve_from.nil? && !p.curve_to.nil? } != nil
          loader.log "a ShapePath CurvePoints contained nil"
        end

        @closed = hash['isClosed']
      end

      def contains_position?(point, view)
        translated_position = view.tp(position) + offset

        # TODO: Sizing ignores zoom
        # TODO: Disgustingly long line
        point.x >= translated_position.x && point.x <= translated_position.x + width && point.y >= translated_position.y && point.y <= translated_position.y + height
      end
    end
  end
end