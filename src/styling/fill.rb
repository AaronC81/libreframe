require_relative '../core/color'

module LibreFrame
  module Styling
    # A class specifying a method of filling.
    class Fill
      attr_writer :enabled
      def enabled?; @enabled; end

      attr_accessor :color

      def initialize(color=nil)
        @enabled = true
        @color = color
      end

      def cairo_draw(ctx)
        ctx.set_source_rgba(*color)
        ctx.fill_preserve
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
      end
    end
  end
end