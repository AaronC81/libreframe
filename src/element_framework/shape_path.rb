require_relative 'element'

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
        translated_point = view.tp(position) + offset

        points.each do |curve_point|
          pt = curve_point.point
          offset = translated_point + pt * Core::Point.new(width, height)
          ctx.line_to(offset.x, offset.y)
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

      # Given the start and end point of a line, returns the new end point if
      # the line's length is altered by a particular delta.
      def change_line_length(s, e, delta)
        divisor = Math.sqrt((e.x - s.x)**2 + (e.y - s.y)**2)

        delta_x = (e.x - s.x) / divisor
        delta_y = (e.y - s.y) / divisor

        Point.new(e.x + delta_x * divisor, e.y + delta_y * divisor)
      end
    end
  end
end