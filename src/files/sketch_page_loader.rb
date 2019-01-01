require_relative '../core/point'
require_relative '../core/audit_hash'

module LibreFrame
  module Files
    # Contains methods to convert Sketch 43+ JSON data into ElementFramework
    # instances.
    class SketchPageLoader
      SKETCH_CLASS_MAP = {
        'rectangle' => ElementFramework::Rectangle,
        'artboard' => ElementFramework::Artboard,
        'group' => ElementFramework::Group,
        'fill' => Styling::Fill,
        'border' => Styling::Stroke,
        'curvePoint' => ElementFramework::CurvePoint,
        'shapePath' => ElementFramework::ShapePath,
        'shapeGroup' => ElementFramework::Group,
        'page' => ElementFramework::Page
      }

      attr_accessor :classes, :log_stream

      def initialize(log_stream, classes=nil)
        @classes = classes || SKETCH_CLASS_MAP
        @log_stream = log_stream
      end

      def dispatch(hash)
        hash = Core::AuditHash.from_hash(hash) unless hash.is_a?(Core::AuditHash)

        unless classes[hash['_class']]
          log "no class #{hash['_class']}"
          return
        end

        instance = classes[hash['_class']].new
        instance.from_sketch_json_hash(hash, self)

        if !hash.non_accessed_keys.empty?
          log "#{hash['_class']} may be incomplete; never accessed #{hash.non_accessed_keys.join(', ')}"
        end

        instance
      end

      def string_to_point(string)
        return nil unless /\{([+-]?(?:[0-9]*[.])?[0-9]+), ([+-]?(?:[0-9]*[.])?[0-9]+)\}/ === string
        Core::Point.new($1.to_f, $2.to_f)
      end

      def log(s)
        log_stream.puts(s)
      end
    end
  end
end
