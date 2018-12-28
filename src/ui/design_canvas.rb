require 'gtk3'
require_relative 'view'
require_relative '../core/point'
require_relative '../core/color'
require_relative 'drag_controller'

module LibreFrame
  module UI
    # A canvas on which designs are displayed.
    class DesignCanvas < Gtk::DrawingArea
      attr_accessor :selection, :elements, :toolbox, :selection_handle
      attr_reader :view, :drag, :handles

      DEBUG_POINT_COLOR = Core::Color.new(1, 0, 0, 1)
      SELECTION_BOX_COLOR = Core::Color.new(0, 0, 1, 0.4)
      BACKGROUND_COLOR = Core::Color.new(0.9, 0.9, 0.9, 1)

      def initialize
        super

        @view = View.new(Core::Point.new(0, 0), 1)
        @drag = DragController.new

        signal_connect 'draw' do
          draw
        end

        # TODO: Have a drag tolerence where nothing happens for tiny accidental
        # drags which should've been selections
        signal_connect 'motion-notify-event' do |_, motion_event|
          # TODO: This doesn't update the toolbox
          if drag.dragging?
            drag.record_position(motion_event.x, motion_event.y) 
            if @selection_handle
              @selection_handle.absolute_position = drag.current_position
            else
              @selection.absolute_position = drag.current_position
            end
            toolbox.draw_properties(@selection) unless toolbox.nil?
          end
          
          queue_draw
        end

        signal_connect 'button-press-event' do |_, button_event|
          point = Core::Point.new(button_event.x, button_event.y)

          clicked_handle = handles.find do |h|
            h.contains_position?(point)
          end

          unless clicked_handle.nil?
            puts "A handle was clicked!"

            drag.start_dragging(clicked_handle.absolute_position)
            @selection_handle = clicked_handle
            next
          end 

          # "Ask" higher-level elements about clicks first
          clicked_element = elements.flat_map(&:onedimensionalize).reverse.find do |el|
            el.contains_position?(point) 
          end

          @selection = clicked_element
          @selection_handle = nil
          toolbox.draw_properties(@selection) unless toolbox.nil?

          drag.start_dragging(@selection.absolute_position) unless @selection.nil?

          queue_draw
        end

        signal_connect 'button-release-event' do |_, button_event|
          drag.reset
        end

        add_events :button_press_mask # TODO: NEED MOTION/RELEASE?
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
        elements.each do |element|
          element.cairo_draw(ctx)
          handles.push(*element.handles)
        end

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