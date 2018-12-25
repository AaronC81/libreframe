require_relative "../core/point"

module LibreFrame
  module Serialization
    # Contains methods to convert Sketch 43+ JSON data into ElementFramework
    # instances.
    class Loader
      attr_accessor :classes, :log_stream

      def initialize(log_stream, classes)
        @classes = classes
        @log_stream = log_stream
      end

      def dispatch(hash)
        unless classes[hash['_class']]
          log "no class #{hash['_class']}"
          return
        end

        instance = classes[hash['_class']].new
        instance.from_sketch_json_hash(hash, self)
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
