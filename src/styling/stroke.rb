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
        
        # Create a new group then paint onto the layer so we can do nifty
        # stroke position hacky stuff
        ctx.push_group

        ctx.set_source_rgba(*color.to_cairo)

        # TODO: Inner not supported
        actual_thickness = ((alignment == :outside || alignment == :inside) ? thickness * 2 : thickness)
        ctx.set_line_width(actual_thickness)
        ctx.stroke_preserve 

        if alignment == :outside
          ctx.save
          ctx.set_source_rgba(1, 1, 1, 0)
          ctx.set_operator(Cairo::OPERATOR_CLEAR)
          ctx.fill_preserve
          ctx.restore
        end

        if alignment == :inside
          if ctx.copy_path.to_a.map(&:class).include?(Cairo::PathCurveTo)
            puts "ignored inside stroke setting due to PathCurveTo segfault bug"
          else
            ctx.save
            ctx.set_source_rgba(1, 1, 1, 1)
            ctx.set_operator(Cairo::OPERATOR_DEST_IN)
            ctx.fill_preserve
            ctx.restore
          end
        end

        ctx.pop_group_to_source
        ctx.paint  
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
        @alignment = [:inside, :center, :outside][hash['position']] # TODO Is this correct?

        @thickness = hash['thickness'].to_f
      end
    end
  end
end