module LibreFrame
  module Styling
    # A class specifying a method of stroking. 
    # Note that .sketch files refer to these as borders, while Cairo (and
    # hence LibreFrame) call them strokes.
    # TODO: Support inner/outer/middle
    # TODO: Thickness
    class Stroke
      attr_writer :enabled
      def enabled?; @enabled; end

      attr_accessor :color, :thickness, :alignment

      def initialize
        @enabled = true
        @color = nil
        @thickness = nil
      end

      def cairo_draw(ctx)
        # FIXME
        if color == nil
          puts "stroke color nil due to a loader bug, skipping draw"
          return
        end

        ctx.set_source_rgba(*color.to_cairo)
        ctx.set_line_width(thickness)
        ctx.stroke_preserve
      end

      def from_sketch_json_hash(hash, loader)
        if hash['fillType'] != 0
          loader.log "unknown fill type #{hash['fillType']}, skipping"
          return
        end

        color_hash = hash['color']
        @color = Core::Color.new(
          color_hash['red'].to_f,
          color_hash['green'].to_f,
          color_hash['blue'].to_f,
          color_hash['alpha'].to_f
        )

        @enabled = hash['isEnabled']

        # Sketch calls inside/outside/center "position", but here it's called
        # alignment to avoid any confusion with points
        @alignment = [:inside, :outside, :center][hash['position']] # TODO Is this correct?

        @thickness = hash['thickness'].to_f
      end
    end
  end
end