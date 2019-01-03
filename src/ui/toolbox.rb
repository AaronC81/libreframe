require 'gtk3'
require_relative '../core/point'

module LibreFrame
  module UI
    # Allows viewing and editing of selected object properties.
    class Toolbox < Gtk::Box
      attr_accessor :canvas

      def initialize
        super(:vertical, 25)

        add_child(Gtk::Label.new("Select something"))
      end

      # Given an element, draws boxes for properties for the element.
      def draw_properties(element)
        # Clear all children
        children.each { |child| remove(child) }

        # Create this element's children from the properties, unless it's nil
        if element.nil?
          add_child(Gtk::Label.new("Select something"))
          show_all
        else
          element.properties.each do |prop|
            prop.canvas = canvas
            add_child(prop.element)
            show_all
          end
        end
      end
    end
  end
end
