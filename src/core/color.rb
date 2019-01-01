module LibreFrame
  module Core
    # Represents an RGBA color, where each value is a decimal between 0 and 1.
    class Color
      attr_accessor :r, :g, :b, :a

      def initialize(r, g, b, a)
        @r = r
        @g = g
        @b = b
        @a = a
      end

      # Converts this color into an array which may be splatted into
      # Cairo::Context#set_source_rgba.
      def to_cairo
        [r, g, b, a]
      end

      # Enable usage with splat operator
      alias to_a to_cairo
    end
  end
end