require_relative '../core/point'
require_relative '../core/audit_hash'
require_relative 'sketch_metadata'

require 'zip'

module LibreFrame
  module Files
    # Represents a loaded .sketch file.
    class SketchDocument
      attr_accessor :metadata

      ##
      # Creates a new, blank .sketch document. A document created this way may
      # not be functional; use +SketchDocument#load_from_file+ instead.
      # @param filename [String] The name of this file.
      def initialize(filename)
        @filename = filename
        @metadata = SketchMetadata.new
      end

      # Loads a Sketch 43+ .sketch document and creates a +SketchDocument+ from
      # it.
      # @param filename [String] The name of the file to load.
      def self.load_from_file(filename, page_loader)
        # Create the document instance
        doc = SketchDocument.new(filename)

        # Read the zip file
        zip_file = Zip::ZipFile.open(filename)

        # Load document metadata
        metadata_json = JSON.parse(zip_file.read('meta.json'))
        doc.metadata = SketchMetadata.new
        doc.metadata.from_sketch_json_hash(metadata_json, zip_file, page_loader)

        # TODO: View data and explicit document data is discarded
        doc
      end
    end
  end
end
