require_relative 'element'

module LibreFrame
  module ElementFramework
    # An abstract class for an element which may have fills and strokes applied
    # to it.
    class StyledElement < Element
      attr_accessor :fills, :strokes

      def initialize
        super
        @fills = []
        @strokes = []
      end

      # Invokes #draw on all of the fills and strokes which this element has, as
      # well as those of any parents.
      def cairo_draw_styles(ctx, view)
        if !parent.nil? && parent.is_a?(StyledElement)
          parent.cairo_draw_styles(ctx, view)
        end

        fills.each do |fill|
          fill.cairo_draw(ctx) if fill.enabled?
        end

        strokes.each do |stroke|
          stroke.cairo_draw(ctx) if stroke.enabled?
        end
      end

      def from_sketch_json_hash(hash, loader)
        super

        unless hash['style'].nil?
          unless hash['style']['fills'].nil?
            @fills = hash['style']['fills']
              .map { |fill| loader.dispatch(fill) }
              .compact
          end

          unless hash['style']['borders'].nil?
            @strokes = hash['style']['borders']
              .map { |stroke| loader.dispatch(stroke) }
              .compact
          end
        end

        nil
      end
    end
  end
end