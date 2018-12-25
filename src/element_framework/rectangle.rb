require_relative 'styled_element'
require_relative 'shape_path'

module LibreFrame
  module ElementFramework
    # Turns out, rectangles can be emulated exactly with shape paths, and
    # they can also be modified just like a shape path so it makes more sense
    # to treat them as such.
    class Rectangle < ShapePath; end
  end
end