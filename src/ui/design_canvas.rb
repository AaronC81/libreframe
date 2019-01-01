require 'gtk3'
require_relative 'view'
require_relative '../core/point'
require_relative '../core/color'
require_relative 'drag_controller'

module LibreFrame
  module UI
    # A canvas on which designs are displayed.
    class DesignCanvas < Gtk::DrawingArea
      attr_accessor :selection, :page, :toolbox, :selection_handle
      attr_reader :view, :drag, :handles

      DEBUG_POINT_COLOR = Core::Color.new(1, 0, 0, 1)
      SELECTION_BOX_COLOR = Core::Color.new(0, 0, 1, 0.4)
      BACKGROUND_COLOR = Core::Color.new(0.9, 0.9, 0.9, 1)

      # Creates a new +DesignCanvas+.
      def initialize
        super

        # Initialize instance variables
        @view = View.new(Core::Point.new(0, 0), 1)
        @drag = DragController.new

        # Connect signal to redraw on resize/move/etc
        signal_connect 'draw' do
          draw
        end

        # Connect mouse movement signal
        signal_connect 'motion-notify-event' do |_, motion_event|
          if drag.dragging?
            # If dragging, add drag point
            drag.record_position(motion_event.x, motion_event.y) 

            # Move the dragged element
            if @selection_handle
              @selection_handle.absolute_position = drag.current_position
            else
              @selection.absolute_position = drag.current_position
            end

            # Reproportion the element if required
            @selection.reproportion if @selection.respond_to?(:reproportion)

            # Redraw toolbox, providing one is linked to this canvas
            toolbox.draw_properties(@selection) unless toolbox.nil?
          end
          
          # Trigger a GTK redraw of the canvas
          queue_draw
        end

        # Connect signal for mouse click
        signal_connect 'button-press-event' do |_, button_event|
          # Handle a handle being clicked (ayyy)
          point = Core::Point.new(button_event.x, button_event.y)
          clicked_handle = handles.find { |h| h.contains_position?(point) }
          unless clicked_handle.nil?
            drag.start_dragging(clicked_handle.absolute_position)
            @selection_handle = clicked_handle
            next
          end 

          # Check if an element was clicked if a handle wasn't
          clicked_element = page.children.flat_map(&:onedimensionalize).reverse.find do |el|
            el.contains_position?(point) 
          end

          # Set selection properties (and reset handle)
          @selection = clicked_element
          @selection_handle = nil

          # Redraw toolbox and start dragging if there's a selection
          toolbox.draw_properties(@selection) unless toolbox.nil?
          drag.start_dragging(@selection.absolute_position) unless @selection.nil?

          # Trigger GTK redraw
          queue_draw
        end

        # Connect signal to reset drag when button up
        signal_connect 'button-release-event' do |_, button_event|
          drag.reset
        end

        add_events :button_press_mask
        add_events :button_release_mask
        add_events :pointer_motion_mask
      end

      # Draws this canvas' elements.
      def draw
        ctx = window.create_cairo_context
        
        # Draw background
        ctx.set_source_rgba(*BACKGROUND_COLOR.to_cairo)
        ctx.rectangle(0, 0, 10000, 10000) # TODO: Actually use widget size
        ctx.fill
      
        # Draw elements
        @handles = []
        page.cairo_draw(ctx)
        handles.push(*page.handles.select { |h| h.element == selection })

        # Begin a new path for UI elements
        ctx.new_path

        # Draw selection bounding box
        unless selection.nil?
          ctx.set_source_rgba(*SELECTION_BOX_COLOR.to_cairo)
          pos = selection.absolute_position
          ctx.rectangle(pos.x, pos.y, selection.width, selection.height)
          ctx.fill
        end

        # Draw any handles
        handles.each do |handle|
          handle.cairo_draw(ctx)
        end
      
        # Draw debug points, if debug mode enabled
        if view.debug?
          ctx.set_source_rgba(*DEBUG_POINT_COLOR.to_cairo)
          view.debug_points.each do |point|
            ctx.rectangle(point.x, point.y, 1, 1)
            ctx.fill
          end
        end
      end
    end
  end
end