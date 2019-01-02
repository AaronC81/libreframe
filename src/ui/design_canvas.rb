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

        # Connect signals
        signal_connect('draw') { draw }
        signal_connect('motion-notify-event') { |_, me| mouse_move(me) }
        signal_connect('button-press-event') { |_, be| button_press(be) }
        signal_connect('button-release-event') { |*| drag.reset }

        # Configure event masks
        add_events :button_press_mask
        add_events :button_release_mask
        add_events :pointer_motion_mask
      end

      # Draws this canvas' elements.
      def draw
        ctx = window.create_cairo_context
        
        # Draw background
        ctx.set_source_rgba(*BACKGROUND_COLOR)
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
          ctx.push_group
          ctx.new_path
          ctx.set_source_rgba(*SELECTION_BOX_COLOR)
          selection.cairo_apply_rotation(ctx)
          ctx.rectangle(
            selection.absolute_position.x,
            selection.absolute_position.y,
            selection.width, selection.height
          )
          ctx.fill
          ctx.pop_group_to_source
          ctx.paint
        end

        # Draw any handles
        handles.each do |handle|
          handle.cairo_draw(ctx)
        end
      
        # Draw debug points, if debug mode enabled
        if view.debug?
          ctx.set_source_rgba(*DEBUG_POINT_COLOR)
          view.debug_points.each do |point|
            ctx.rectangle(point.x, point.y, 1, 1)
            ctx.fill
          end
        end
      end

      # Handles a mouse movement.
      # @param motion_event [Any] An object with +#x+ and +#y+ methods
      #   representing the new mouse position.
      def mouse_move(motion_event)
        # There's nothing to do if we're not dragging
        return unless drag.dragging?

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
        
        # Trigger a GTK redraw of the canvas
        queue_draw
      end

      # Handles a mouse button event.
      # @param button_event [Any] An object with +#x+ and +#y+ methods
      #   describing the mouse position at the time of the event.
      def button_press(button_event)
        # Handle a handle being clicked (ayyy)
        point = Core::Point.new(button_event.x, button_event.y)
        clicked_handle = handles.find { |h| h.contains_position?(point) }
        unless clicked_handle.nil?
          drag.start_dragging(clicked_handle.absolute_position)
          @selection_handle = clicked_handle
          return
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
    end
  end
end