require_relative 'src/ui/app_window'
require_relative 'src/element_framework/rectangle'
require_relative 'src/element_framework/artboard'
require_relative 'src/styling/solid_fill'
require_relative 'src/styling/solid_stroke'

require 'json'

json = JSON.parse(File.read('data/g_translate.json'))

include LibreFrame

def shape_for_hash(hash)    
  fm = hash['frame']
  rect = ElementFramework::Rectangle.new(
    Core::Point.new(fm['x'].to_i, fm['y'].to_i), fm['width'].to_i, fm['height'].to_i, [
      Styling::SolidStroke.new([1, 1, 1]),
      Styling::SolidFill.new([0.5, 0.5, 1])
    ]
  )

  unless hash['layers'].nil?
    hash['layers'].each do |layer|
      rect.add_child(shape_for_hash(layer))
    end
  end

  rect
end

abd = ElementFramework::Artboard.new(Core::Point.new(10, 10), 100, 100)
abd.add_child(shape_for_hash(json))

w = UI::AppWindow.new
w.canvas.queue_element_draw([
  abd
])
w.show_all

Gtk.main
