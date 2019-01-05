require_relative '../core/point'
require_relative '../core/audit_hash'

require_relative '../element_framework/page'
require_relative '../element_framework/shape_group'

module LibreFrame
  module Files
    # Contains methods to convert Sketch 43+ JSON data into ElementFramework
    # instances.
    class SketchPageLoader
      # The default for the +classes+ parameter of +SketchPageLoader+'s
      # constructor.
      SKETCH_CLASS_MAP = {
        'rectangle' => ElementFramework::Rectangle,
        'artboard' => ElementFramework::Artboard,
        'group' => ElementFramework::Group,
        'fill' => Styling::Fill,
        'border' => Styling::Stroke,
        'curvePoint' => ElementFramework::CurvePoint,
        'shapePath' => ElementFramework::ShapePath,
        'shapeGroup' => ElementFramework::ShapeGroup,
        'page' => ElementFramework::Page
      }

      attr_accessor :classes, :log_stream

      # Creates a new +SketchPageLoader+.
      # @param log_stream [IO] An object which responds to +#puts+ which 
      #   informational messages or warnings will be printed to.
      # @param classes [Hash] A mapping of Sketch _class values to 
      #   Element subclasses. Defaults to +SKETCH_CLASS_MAP+.
      def initialize(log_stream, classes=nil)
        @classes = classes || SKETCH_CLASS_MAP
        @log_stream = log_stream
      end

      # Dispatches the loader on a Hash, creating an instance of an Element
      # subclass according to its contents.
      # @param hash [Hash] The Hash to convert to an Element.
      # @return [ElementFramework::Element] An instance of some Element,
      #   according to the +_class+ mappings specified in +classes+.
      def dispatch(hash)
        # Convert to an AuditHash, unless it already is one
        hash = Core::AuditHash.from_hash(hash) unless hash.is_a?(Core::AuditHash)

        # Ignore if class is unknown
        unless classes[hash['_class']]
          log "no class #{hash['_class']}"
          return
        end

        # Instantiate and populate keys
        instance = classes[hash['_class']].new
        instance.from_sketch_json_hash(hash, self)

        # Warn if any keys were never accessed (could indicate incomplete
        # support for a particular element)
        if !hash.non_accessed_keys.empty?
          log "#{hash['_class']} may be incomplete; never accessed #{hash.non_accessed_keys.join(', ')}"
        end

        instance
      end

      # Converts a Sketch shorthand point, specified between braces, into a
      # +Core::Point+.
      # @param string [String] The string to convert.
      # @return [Core::Point] The point represented by +string+.
      def string_to_point(string)
        # TODO: Does this method belong in SketchPageLoader?
        return nil unless /\{([+-]?(?:[0-9]*[.])?[0-9]+), ([+-]?(?:[0-9]*[.])?[0-9]+)\}/ === string
        Core::Point.new($1.to_f, $2.to_f)
      end

      # Writes to +log_stream+ using +#puts+.
      # @param s [String] The string to write.
      # @return [Any] Whatever +log_stream#puts+ returns. Do not rely upon
      #   this value.
      def log(s)
        log_stream.puts(s)
      end
    end
  end
end
