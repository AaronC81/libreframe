require 'gtk3'
require_relative 'view'
require_relative '../core/point'
require_relative '../core/color'

module LibreFrame
  module UI
    # A canvas on which designs are displayed.
    class DesignCanvas < Gtk::DrawingArea
      attr_accessor :selection, :elements, :toolbox
      attr_reader :view

      DEBUG_POINT_COLOR = Core::Color.new(1, 0, 0, 1)
      SELECTION_BOX_COLOR = Core::Color.new(0, 0, 1, 0.4)
      BACKGROUND_COLOR = Core::Color.new(0.9, 0.9, 0.9, 1)

      def initialize
        super

        @view = View.new(Core::Point.new(0, 0), 1)

        signal_connect 'draw' do
          draw
        end

        #signal_connect 'motion-notify-event' do |_, motion_event|
        #  @view.origin_point.x = motion_event.x
        #  @view.origin_point.y = motion_event.y
        #  queue_draw
        #end

        signal_connect 'button-press-event' do |_, button_event|
          # "Ask" higher-level elements about clicks first
          clicked_element = elements.flat_map(&:onedimensionalize).reverse.find do |el|
            point = Core::Point.new(button_event.x, button_event.y)
            el.contains_position?(point) 
          end

          @selection = clicked_element
          toolbox.draw_properties(@selection) unless toolbox.nil?

          queue_draw
        end

        set_events :button_press_mask
      end

      # Draws this canvas' elements.
      def draw
        ctx = window.create_cairo_context
        
        # Draw background
        ctx.set_source_rgba(*BACKGROUND_COLOR.to_cairo)
        ctx.rectangle(0, 0, 10000, 10000) # TODO: Actually use widget size
        ctx.fill
      
        # Draw elements
        elements.each do |element|
          element.cairo_draw(ctx)
        end

        ctx.new_path

        # Draw selection bounding box
        unless selection.nil?
          ctx.set_source_rgba(*SELECTION_BOX_COLOR.to_cairo)
          pos = selection.absolute_position
          ctx.rectangle(pos.x, pos.y, selection.width, selection.height)
          ctx.fill
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