require_relative '../../core/pathing'
require_relative '../../element_framework/styled_element'

module LibreFrame
  module UI
    module Cairo
      # Handles painting onto a Cairo canvas using the "drawing path" system.
      # This class aims to replace Element#cairo_draw.
      class Painter
        attr_reader :ctx

        def initialize(ctx)
          @ctx = ctx
        end

        def draw_element(element)
          # Get the paths for an element
          paths = element.drawing_paths
          
          # Plot each path
          paths.each do |path|
            Core::Pathing.cairo_plot(ctx, path)
          end

          # Apply styling
          element.cairo_apply_styles(ctx)

          # Draw children, if requested
          if element.draw_child_paths?
            element.children.each do |child|
              draw_element(child)
            end
          end
        end
      end
    end
  end
end