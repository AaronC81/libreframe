require_relative 'src/ui/app_window'
require_relative 'src/element_framework/rectangle'
require_relative 'src/element_framework/artboard'
require_relative 'src/element_framework/group'
require_relative 'src/element_framework/shape_path'
require_relative 'src/element_framework/curve_point'
require_relative 'src/styling/fill'
require_relative 'src/styling/solid_stroke'
require_relative 'src/serialization/loader'

require 'json'
require 'pp'

include LibreFrame

# TODO: Strokes
loader = Serialization::Loader.new($stdout, {
  'rectangle' => ElementFramework::Rectangle,
  'artboard' => ElementFramework::Artboard,
  'group' => ElementFramework::Group,
  'fill' => Styling::Fill,
  'curvePoint' => ElementFramework::CurvePoint,
  'shapePath' => ElementFramework::ShapePath
})

hash = JSON.parse(File.read('data/g_translate.json'))
artboards = hash['layers'].map { |x| loader.dispatch(x) }
p artboards

w = UI::AppWindow.new
w.canvas.queue_element_draw(
  artboards
)
w.show_all

Gtk.main
