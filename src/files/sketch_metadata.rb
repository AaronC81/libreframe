module LibreFrame
  module Files
    # Represents the metadata of a loaded .sketch file, namely the contents
    # of its meta.json file.
    class SketchMetadata
      attr_accessor :pages, :fonts, :version

      # Fills the properties of this instance from a Sketch JSON hash.
      # @param [Hash] hash The Sketch JSON hash.
      def from_sketch_json_hash(hash)
        @fonts = hash['fonts']
        @version = hash['version']

        # TODO: Pages
      end
    end
  end
end
