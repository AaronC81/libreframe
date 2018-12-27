require 'gtk3'
require_relative 'design_canvas'
require_relative 'toolbox'

module LibreFrame
  module UI
    # The main application window in which designs may be edited.
    class AppWindow < Gtk::Window
      attr_accessor :canvas, :toolbox, :hbox

      def initialize
        super

        # Kill the app when this window is closed
        signal_connect 'delete-event' do
          Gtk.main_quit
        end

        @canvas = DesignCanvas.new
        canvas.set_size_request 800, 500

        @toolbox = Toolbox.new

        canvas.toolbox = toolbox
        toolbox.canvas = canvas

        @hbox = Gtk::Box.new(:horizontal, 3)
        hbox.add(toolbox)
        hbox.add(canvas)

        add(hbox)
        show_all
      end
    end
  end
end
