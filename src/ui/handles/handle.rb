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

        attr_accessor :element, :property, :size, :style, :other_properties

        def initialize(element, property, other_properties=nil, size=3, style=:square)
          @element = element
          @property = property
          @other_properties = other_properties || []
          @size = size
          @style = style
        end

        def absolute_position
          property.getter.()
        end

        def absolute_position=(value)
          property.setter.(value)
        end

        def properties
          @other_properties
        end

        def width
          size
        end

        def height
          size
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
          ctx.set_source_rgba(*FILL_COLOR)
          ctx.fill_preserve
          ctx.set_source_rgba(*STROKE_COLOR)
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