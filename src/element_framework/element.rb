require_relative '../ui/property'

module LibreFrame
  module ElementFramework
    # A basic, abstract element which is part of a document. Elements may have
    # children unless #accepts_children is false.
    class Element
      attr_accessor :children, :parent, :position, :width, :height, :do_object_id, :rotation, :name
      bool_reader :accepts_children
      attr_writer :view, :canvas

      def initialize
        @children = []
        @accepts_children = true
      end

      # Gets the view associated with this element.
      def view
        @view ? @view : (parent ? parent.view : nil)
      end

      # Gets the canvas on which this element is drawn.
      def canvas
        @canvas ? @canvas : (parent ? parent.canvas : nil)
      end

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

      # Gets the rotation which must be applied to this element based on the
      # rotation of its parent elements.
      def rotation_offset
        parents = []
        curr = parent
        until curr.nil?
          parents << curr
          curr = curr.parent
        end

        parents.map(&:rotation).sum
      end

      # Returns an array of paths of points constituing the paths drawn to draw
      # this shape onto a canvas. Multiple paths will be drawn using an 
      # even-odd operator, allowing holes to be cut out of shapes.
      # @return [Array<Array<Core::Point>>] The paths required to plot this.
      def drawing_paths
        puts "WARNING: Default #drawing_paths implementation used"
        []
      end

      # Instructs a drawing path painter whether to automatically draw children.
      def draw_child_paths?
        true
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
        context.push_group
        context.new_path

        children.each do |c|
          context.save
          c.cairo_apply_rotation(context)
          c.cairo_draw(context)
          context.restore
        end

        context.pop_group_to_source
        context.paint
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
      rescue
        # TODO: Sort this out
        puts "warning: Element#absolute_position threw"
        Core::Point.new(0, 0)
      end

      # Sets the absolute position of this element by mapping it to a relative
      # one and setting that instead.
      def absolute_position=(value)
        @position = value - offset
      end

      # Returns the total rotation of this element with respect to its parent.
      def total_rotation
        rotation + rotation_offset
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
        @rotation = hash['rotation'].to_f
        @name = hash['name']

        # Populate children
        unless hash['layers'].nil?
          hash['layers'].each do |layer|
            child_instance = loader.dispatch(layer)
            add_child(child_instance) unless child_instance.nil?
          end
        end

        nil
      end

      # Returns a list of properties which may be set on this object.
      def properties
        [
          # TODO: Join these together like position
          UI::Property.from_attribute('ID', self, :do_object_id),
          UI::Property.from_attribute('Width', self, :width),
          UI::Property.from_attribute('Height', self, :height),
          UI::Property.from_attribute('Position', self, :absolute_position),
          UI::Property.from_attribute('Rotation', self, :rotation)
        ]
      end

      # Given a Cairo context, applies a transformation matrix which rotates
      # elements to be drawn around the center of this element.
      # @param ctx [Cairo::Context] The Cairo context to mutate.
      def cairo_apply_rotation(ctx)
        ctx.translate(center.x, center.y)
        ctx.rotate(rotation)
        ctx.translate(-center.x, -center.y)
      end

      # Returns the handles which should be rendered along with this element.
      def handles
        children.flat_map(&:handles)
      end

      # Calculates the centre of this element, based on its size and position.
      def center
        Core::Point.new(
          absolute_position.x + width / 2,
          absolute_position.y + height / 2
        )
      end

      def inspect
        "<##{self.class} (#{do_object_id}), #{position} #{width}x#{height}"
      end
      alias to_s inspect
    end
  end
end