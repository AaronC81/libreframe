require 'zip'
require 'json'

module LibreFrame
  module Files
    # Represents the metadata of a loaded .sketch file, namely the contents
    # of its meta.json file.
    class SketchMetadata
      attr_accessor :pages, :fonts, :version, :document

      # Fills the properties of this instance from a Sketch JSON hash.
      # Requires that +#document+ has been set.
      # @param hash [Hash] The Sketch JSON hash.
      # @param zip_file [Zip::ZipFile] An optional reference to the zip file
      #   which this metadata was read from. An exception will be raised if
      #   the document has any pages but this parameter was not specified, since
      #   this parameter will be used to load the files for the pages.
      # @param page_loader [SketchPageLoader] An optional instance of
      #   SketchPageLoader for creating Elements from each page. An exception 
      #   will be raised if the document has any pages but this parameter was
      #   not specified.
      def from_sketch_json_hash(hash, zip_file=nil, page_loader=nil)
        @fonts = hash['fonts']
        @version = hash['version']
        @pages = hash['pagesAndArtboards'].map do |name, _|
          # TODO: Each page has a name and list of artboards as a key. Is this
          # relevant?
          
          # Check required parameters specified
          raise 'zip_file not given' if zip_file.nil?
          raise 'page_loader not given' if page_loader.nil?

          # Load page from file and convert to Page using page_loader
          page_contents = JSON.parse(zip_file.read("pages/#{name}.json"))
          page_loader.dispatch(page_contents)
        end
      end
    end
  end
end
