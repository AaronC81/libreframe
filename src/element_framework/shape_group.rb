require 'clipper'

require_relative 'element'

module LibreFrame
  module ElementFramework
    # A group of other elements which are drawn on the same "plane" using
    # boolean operations. This enables the shapes to blend together.
    class ShapeGroup < StyledElement

      def draw_child_paths?
        false
      end 

      def drawing_paths
        # Prepare a clipper instance
        clipper = Clipper::Clipper.new
        current_subject_paths = []
      
        children.each do |child|
          # Load subject polygons
          current_subject_paths.each do |subject_path|
            clipper.add_subject_polygon(subject_path)
          end

          # Load this ShapePath and use it to clip
          child.drawing_paths.each do |clip_path|
            clipper.add_clip_polygon(clip_path.map { |pt| [pt.x, pt.y] })
          end

          # TODO: Make this actually detect op
          current_subject_paths = clipper.union

          clipper.clear!
        end

        current_subject_paths.map do |path|
          path.map { |pt| Core::Point.new(*pt) }
        end
      end
    end
  end
end