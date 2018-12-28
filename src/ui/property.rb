require_relative '../core/point'

module LibreFrame
  module UI
    # Represents a property which may be altered by the user.
    # This property is rather abstract; getters and setters are specified using
    # callables (anything supporting #.()).
    class Property
      attr_accessor :name, :description, :getter, :setter, :canvas

      def initialize(name, getter, setter, description='')
        @name = name
        @getter = getter
        @setter = setter
        @description = description
      end

      def self.from_attribute(name, instance, attribute, description='')
        Property.new(
          name,
          ->{ instance.send(attribute) },
          ->x{ instance.send(attribute.to_s + '=', x) },
          description
        )
      end

      def convert(value, reference)
        case reference
        when String
          value
        when Integer
          value.to_i
        when Float
          value.to_f
        when Core::Point
          Core::Point.new(value[0].to_f, value[1].to_f)
        else
          raise "unable to convert value of #{value.class}"
        end
      end

      def element
        raise 'cannot use property before setting canvas' if @canvas.nil?

        # Create a box for this property
        property_box = Gtk::Box.new(:vertical, 1)
        property_box.add_child(Gtk::Label.new(name))

        # Match against the type of this property
        case getter.()
        when String, Integer, Float
          # We're dealing with a simple, primitive type
          # Create a text box
          entry = Gtk::Entry.new
          entry.text = getter.().to_s
          entry.signal_connect 'changed' do
            setter.(convert(entry.text, getter.()))
            @canvas.queue_draw
          end
          property_box.add(entry)

        when Core::Point
          # Create two text boxes for a point
          entry_x = Gtk::Entry.new
          entry_y = Gtk::Entry.new

          entry_x.text = getter.().x.to_s
          entry_x.signal_connect 'changed' do |val|
            setter.(convert([entry_x.text, entry_y.text], getter.()))
            @canvas.queue_draw
          end
          property_box.add(entry_x)

          entry_y.text = getter.().y.to_s
          entry_y.signal_connect 'changed' do |val|
            setter.(convert([entry_x.text, entry_y.text], getter.()))
            @canvas.queue_draw
          end
          property_box.add(entry_y)

        when NilClass
          property_box.add(Gtk::Label.new("(nil)"))

        else
          raise 'unknown property type'
        end

        property_box
      end
    end
  end
end