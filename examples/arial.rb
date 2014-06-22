require 'openscad-text'

font = Text.available_fonts.find { |f| f =~ /arial/ }
text = Text.new("Arial!", font)
puts text.to_openscad
