openscad-text
=============
A ruby gem to generate text in openscad with system fonts easily.

Installation:
-------------
You need ```ruby``` installed on your machine, on linux simply type:

    \curl -sSL https://get.rvm.io | bash -s stable --with-gems="openscad-text"

This will install the ```ruby``` interpreter and the ```openscad-text``` gem.

Those who already have ruby installed can simply type the following to install the gem:

    gem install openscad-text

Usage:
------
Create a file called ```nice_text.rb``` with the following content:

    require 'openscad-text'
    
    font = Text.available_fonts.find { |f| f =~ /times/ }
    text = Text.new("Nice Text!", font)
    puts text.to_openscad

If you're on Linux you can use the little script above like so:

    ruby nice_text.rb > nice_text.scad

This will create a new file called ```nice_text.scad```, which will contain the text as openscad model.

Have a look at the [examples/](https://github.com/flo-l/openscad-text/tree/master/examples) directory to see more! ;)

Examples:
---------
![Times new Roman!](http://i59.tinypic.com/2pq5278.png)
![Comic Sans!](http://i61.tinypic.com/23h65y1.png)
![Arial](http://i62.tinypic.com/2cs9ta0.png)
