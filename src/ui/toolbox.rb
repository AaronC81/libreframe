require 'gtk3'
require_relative '../core/point'

module LibreFrame
  module UI
    # Allows viewing and editing of selected object properties.
    class Toolbox < Gtk::Box
      def initialize
        super(:vertical, 5)

        add_child(Gtk::Label.new("Select something"))
      end

      # Given an element, draws boxes for properties for the element.
      def draw_properties(element, view)
        # Clear all children
        children.each { |child| remove(child) }

        # Create this element's children from the properties, unless it's nil
        if element.nil?
          add_child(Gtk::Label.new("Select something"))
          show_all
        else
          element.properties.each do |prop|
            el = element_for_property(element, prop, view)
            add_child(el)
            show_all
          end
        end
      end

      def element_for_property(element, prop, view)
        # If the property requires an argument, it must be a view
        if element.method(prop).arity == 1
          prop_val = element.send(prop, view)
        else
          prop_val = element.send(prop)
        end
        p prop_val.class

        property_box = Gtk::Box.new(:vertical, 1)
        property_box.add_child(Gtk::Label.new(prop))

          setter = (prop.to_s + '=').to_sym

        if prop_val.is_a?(String) || prop_val.is_a?(Numeric)
          entry = Gtk::Entry.new
          entry.text = prop_val.to_s
          entry.signal_connect 'changed' do
            if prop_val.is_a?(String)
              element.send(setter, entry.text)
            elsif prop_val.is_a?(Integer)
              element.send(setter, entry.text.to_i)
            elsif prop_val.is_a?(Float)
              element.send(setter, entry.text.to_f)
            end
          end

          property_box.add_child(entry)

        elsif prop_val.is_a?(Core::Point)
          x_entry = Gtk::Entry.new
          y_entry = Gtk::Entry.new

          x_entry.text = prop_val.x.to_s
          x_entry.signal_connect 'changed' do
            element.send(setter, Core::Point.new(x_entry.text.to_f, y_entry.text.to_f))
          end
          property_box.add_child(x_entry)

          y_entry.text = prop_val.y.to_s
          y_entry.signal_connect 'changed' do
            element.send(setter, Core::Point.new(x_entry.text.to_f, y_entry.text.to_f))
          end
          property_box.add_child(y_entry)
        # TODO: Boolean?
        else
          property_box.add_child(Gtk::Label.new("Can't interpret #{prop_val.class}: #{prop_val}"))
        end

        property_box.show_all
        property_box
      end
    end
  end
end
