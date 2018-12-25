require 'gtk3'
require_relative 'design_canvas'

module LibreFrame
  module UI
    # The main application window in which designs may be edited.
    class AppWindow < Gtk::Window
      attr_accessor :canvas

      def initialize
        super

        # Kill the app when this window is closed
        signal_connect 'delete-event' do
          Gtk.main_quit
        end

        @canvas = DesignCanvas.new
        canvas.set_size_request 100, 100
        add(canvas)
        canvas.show
      end
    end
  end
end
