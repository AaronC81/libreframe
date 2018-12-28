require 'gtk3'
require_relative 'design_canvas'
require_relative 'toolbox'

module LibreFrame
  module UI
    # The main application window in which designs may be edited.
    class AppWindow < Gtk::Window
      attr_accessor :canvas, :toolbox, :hbox

      TOOLBOX_WIDTH = 200

      def initialize
        super

        # Kill the app when this window is closed
        signal_connect 'delete-event' do
          Gtk.main_quit
        end

        @canvas = DesignCanvas.new
        @toolbox = Toolbox.new

        canvas.toolbox = toolbox
        toolbox.canvas = canvas

        canvas.set_size_request(400, 400)
        canvas.hexpand = true
        canvas.vexpand = true
        toolbox.set_size_request(TOOLBOX_WIDTH, allocation.height)

        @hbox = Gtk::Box.new(:horizontal, 3)
        hbox.add(toolbox)
        hbox.add(canvas)

        add(hbox)
        show_all
      end
    end
  end
end
