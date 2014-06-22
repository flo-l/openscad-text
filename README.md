openscad-text
=============
A ruby gem to generate text in openscad with system fonts easily

Installation:
-------------
    gem install openscad-text

Usage:
------
nice_text.rb:

    require 'openscad-text'
    
    font = Text.available_fonts.find { |f| f =~ /times/ }
    text = Text.new("Nice Text!", font)
    puts text.to_openscad

If you're on Linux you could use the little script above like so:

    ruby nice_text.rb > nice_text.scad

This will create a new file called ```nice_text.scad```, which will contain the text as openscad model.

Have a look at the [examples/](https://github.com/flo-l/openscad-text/tree/master/examples) directory to see more! ;)

Examples:
---------
![Times new Roman!](http://i59.tinypic.com/2pq5278.png)
![Comic Sans!](http://i61.tinypic.com/23h65y1.png)
![Arial](http://i62.tinypic.com/2cs9ta0.png)
