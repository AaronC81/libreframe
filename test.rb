require_relative 'src/ui/app_window'
require_relative 'src/element_framework/rectangle'
require_relative 'src/element_framework/artboard'
require_relative 'src/element_framework/group'
require_relative 'src/element_framework/shape_path'
require_relative 'src/element_framework/curve_point'
require_relative 'src/styling/fill'
require_relative 'src/styling/stroke'
require_relative 'src/files/sketch_page_loader'

require 'json'
require 'pp'

include LibreFrame

loader = Files::SketchPageLoader.new($stdout, )

hash = JSON.parse(File.read('data/showcase.json'))
artboards = hash['layers'].map { |x| loader.dispatch(x) }
p artboards

w = UI::AppWindow.new
artboards.each { |a| a.view = w.canvas.view; a.canvas = w.canvas }
w.canvas.elements = artboards
w.canvas.view.debug = false
w.show_all

Gtk.main
