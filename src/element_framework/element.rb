require_relative '../ui/property'

module LibreFrame
  module ElementFramework
    # A basic, abstract element which is part of a document. Elements may have
    # children unless #accepts_children is false.
    # TODO: Rotation
    class Element
      attr_accessor :children, :parent, :position, :width, :height, :do_object_id, :rotation
      attr_writer :view

      def initialize
        @children = []
        @parent = nil
        @accepts_children = true
        @do_object_id = nil
        @rotation = nil
        @position = nil
        @width = nil
        @height = nil
      end

      # Gets the view associated with this element.
      def view
        @view ? @view : (parent ? parent.view : nil)
      end

      # A boolean indicating whether this element can have children.
      def accepts_children?; @accepts_children; end

      # Adds a child to this element. The element's parent is set to this
      # element.
      def add_child(child)
        raise 'this element does not accept children' unless accepts_children?

        @children << child
        child.parent = self
      end

      # Gets the offset which must be applied to this element's position based
      # on the parents of this element.
      def offset
        parents = []
        curr = parent
        until curr.nil?
          parents << curr
          curr = curr.parent
        end

        parents.map(&:position).inject(Core::Point.new(0, 0), :+)
      end

      # Draws this element onto a Gtk3 Cairo graphics context. This abstract
      # implementation simply throws an exception, so subclasses MUST NOT
      # invoke super in their implementations. If the element has children, it
      # should usually draw them too using #cairo_draw_children.
      def cairo_draw(context)
        raise 'this element cannot be drawn (tried to draw abstract Element)'
      end

      # Draws all of the children of this element onto a Gtk3 Cairo graphics
      # context by invoking their #cairo_draw implementations.
      def cairo_draw_children(context)
        children.each do |c|
          context.new_path
          c.cairo_draw(context)
        end
      end

      # Represents this element and all of its children, and of the childrens'
      # children, etc. as an array.
      def onedimensionalize
        [self] + children.flat_map(&:onedimensionalize)
      end

      # Returns the absolute position of this element with respect to a
      # particular view.
      def absolute_position
        view.tp(position) + offset
      end

      def absolute_position=(value)
        # TODO: THIS NEEEEDS TO ACCESS THE VIEW SOMEHOW.
        # I think we need a better solution than throwing a parameter around
        # everywhere
        @position = value - offset
      end

      # Returns a boolean indicating whether this element contains a certain
      # click position when rendered in a view. By default, this is
      # unimplemented and always returns false.
      def contains_position?(point)
        false
      end

      # Applies properties from a Sketch JSON hash of this element to this 
      # instance of the element. Subclasses should override this.
      def from_sketch_json_hash(hash, loader)
        # Populate position and size
        @position = Core::Point.new(
          hash['frame']['x'].to_f,
          hash['frame']['y'].to_f
        )
        @width = hash['frame']['width'].to_f
        @height = hash['frame']['height'].to_f
        @do_object_id = hash['do_objectID']
        @rotation = hash['rotation']

        # Populate children
        unless hash['layers'].nil?
          hash['layers'].each do |layer|
            child_instance = loader.dispatch(layer)
            add_child(child_instance) unless child_instance.nil?
          end
        end

        nil
      end

      # Returns a list of properties which may be set on this object. Currently
      # this is just a list of symbols, but this could be developed much
      # further.
      def properties
        [
          UI::Property.from_attribute('Height', self, :height),
          UI::Property.from_attribute('Width', self, :width),
          UI::Property.from_attribute('Position', self, :absolute_position),
          UI::Property.from_attribute('Rotation', self, :rotation)
        ]
      end

      def inspect
        "<##{self.class} (#{do_object_id}), #{position} #{width}x#{height}"
      end
      alias to_s inspect
    end
  end
end