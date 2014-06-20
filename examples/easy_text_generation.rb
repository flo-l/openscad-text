require 'openscad-text'

# The available_fonts method returns an array of font_paths found on the
# system. It checks all directories in the Text::FONT_DIRECTORIES array.
font = Text.available_fonts.find { |f| f =~ /times/ }

# Text.new takes two arguments, the text string and the font.
# If no font is given one will be picked automatically.
text = Text.new("Times new Roman!", font)

# Produces a string, which is an openscad script that renders to a
# 2D polygon representing the given text string in the given font.
puts text.to_openscad

# Feel free to check out the result of this script!
# File: easy_text_generation.scad
