require_relative 'src/ui/app_window'
require_relative 'src/element_framework/rectangle'
require_relative 'src/element_framework/artboard'
require_relative 'src/element_framework/group'
require_relative 'src/element_framework/shape_path'
require_relative 'src/element_framework/curve_point'
require_relative 'src/styling/fill'
require_relative 'src/styling/stroke'
require_relative 'src/files/sketch_page_loader'
require_relative 'src/files/sketch_document'

require 'json'
require 'pp'

include LibreFrame

doc_loader = Files::SketchDocument.load_from_file('/home/aaron/Downloads/Test.sketch', Files::SketchPageLoader.new($stdout))
doc_loader.metadata

w = UI::AppWindow.new
doc_loader.metadata.pages.first.children.each { |a| a.view = w.canvas.view; a.canvas = w.canvas }
w.canvas.page = doc_loader.metadata.pages.first
w.canvas.view.debug = false
w.show_all

Gtk.main
