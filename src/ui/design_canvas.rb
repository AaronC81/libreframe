require 'gtk3'
require_relative 'view'
require_relative '../core/point'

module LibreFrame
  module UI
    # A canvas on which designs are displayed.
    class DesignCanvas < Gtk::DrawingArea
      attr_accessor :view

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
          clicked_element = @elements.flat_map(&:onedimensionalize).reverse.find do |el|
            point = Core::Point.new(button_event.x, button_event.y)
            el.contains_position?(point, view) 
          end

          p clicked_element
        end

        set_events :button_press_mask
      end

      # Queues a collection of elements onto this canvas.
      def queue_element_draw(elements)
        @elements = elements
        queue_draw
      end

      # Draws this canvas' elements.
      def draw
        ctx = window.create_cairo_context
        
        @elements.each do |element|
          element.cairo_draw(ctx, view)
        end

        if view.debug?
          view.debug_points.each do |point|
            ctx.set_source_rgb(1, 0, 0)
            ctx.rectangle(point.x, point.y, 1, 1)
            ctx.fill
          end
        end
      end
    end
  end
end