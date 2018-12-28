require_relative '../../core/color'

module LibreFrame
  module UI
    module Handles
      # Represents a mapping between a canvas-drawn UI component and another
      # non-Element class. This handle may be dragged around, synchronising
      # its Point value with some other property.
      class Handle
        FILL_COLOR = Core::Color.new(1, 1, 1, 1)
        STROKE_COLOR = Core::Color.new(1, 0, 0, 1)

        attr_accessor :property, :size, :style

        def initialize(property, size=3, style=:square)
          @property = property
          @size = size
          @style = style
        end

        # Draws this handle onto a canvas.
        def cairo_draw(ctx)
          ctx.save
          ctx.new_path
          ctx.rectangle(
            property.getter.().x - size,
            property.getter.().y - size,
            size * 2,
            size * 2
          )
          ctx.set_source_rgba(*FILL_COLOR.to_cairo)
          ctx.fill_preserve
          ctx.set_source_rgba(*STROKE_COLOR.to_cairo)
          ctx.stroke

          ctx.restore
        end

        # Checks whether this handle contains a point.
        def contains_position?(point)
          case style
          when :square
            (property.getter.().x - point.x).abs <= size &&  
              (property.getter.().y - point.y).abs <= size 
          else
            raise 'invalid handle style'
          end
        end
      end
    end
  end
end