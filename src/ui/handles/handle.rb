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
        SIZE = 3
        STROKE_WIDTH = 2

        attr_accessor :element, :property, :style, :other_properties

        def initialize(element, property, other_properties=nil, style=:square)
          @element = element
          @property = property
          @other_properties = other_properties || []
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
          SIZE
        end

        def height
          SIZE
        end

        # Draws this handle onto a canvas.
        def cairo_draw(ctx)
          ctx.save
          ctx.new_path
          ctx.rectangle(
            property.getter.().x - SIZE,
            property.getter.().y - SIZE,
            SIZE * 2,
            SIZE * 2
          )
          ctx.set_source_rgba(*FILL_COLOR)
          ctx.fill_preserve
          ctx.set_source_rgba(*STROKE_COLOR)
          ctx.line_width = STROKE_WIDTH
          ctx.stroke

          ctx.restore
        end

        # Checks whether this handle contains a point.
        def contains_position?(point)
          case style
          when :square
            (property.getter.().x - point.x).abs <= SIZE &&  
              (property.getter.().y - point.y).abs <= SIZE 
          else
            raise 'invalid handle style'
          end
        end
      end
    end
  end
end