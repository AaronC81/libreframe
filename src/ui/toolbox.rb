require 'gtk3'

module LibreFrame
  module UI
    # Allows viewing and editing of selected object properties.
    class Toolbox < Gtk::Box
      def initialize
        super(:vertical, 5)

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
            el = element_for_property(element, prop)
            add_child(el)
            show_all
          end
        end
      end

      def element_for_property(element, prop)
        prop_val = element.send(prop)
        p prop_val.class

        if prop_val.is_a?(String) || prop_val.is_a?(Numeric)
          Gtk::Label.new("#{prop} is #{element.send(prop)}")
        # TODO: Boolean?
        else
          Gtk::Label.new("#{prop_val}?")
        end
      end
    end
  end
end
