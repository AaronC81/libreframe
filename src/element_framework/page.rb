require_relative 'element'
require_relative '../extensions/module'

module LibreFrame
  module ElementFramework
    # A page which contains any number of artboards. A document may have several
    # pages. The children of a page are +Artboard+ instances.
    class Page < Element
      # TODO: Many properties not implemented
      bool_accessor :locked, :visible

      def from_sketch_json_hash(hash, loader)
        super

        @locked = hash['isLocked']
        @visible = hash['isVisible']
      end

      def drawing_paths
        []
      end

      def cairo_draw_styles(ctx); end
    end
  end
end