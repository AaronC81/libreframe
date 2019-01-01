require_relative 'element'
require_relative '../extensions/module'

module LibreFrame
  module ElementFramework
    # A page which contains any number of artboards. A document may have several
    # pages.
    class Page < Element
      # TODO: Many properties not implemented
      bool_accessor :locked, :visible

      def from_sketch_json_hash(hash)
        super

        @locked = hash['isLocked']
        @visible = hash['isVisible']
      end
    end
  end
end