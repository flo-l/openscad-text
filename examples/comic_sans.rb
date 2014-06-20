require 'openscad-text'

font = Text.available_fonts.find { |f| f =~ /comic/ }
text = Text.new("Comic Sans!", font)
puts text.to_openscad
