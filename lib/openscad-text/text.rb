# Represents a Text with a font
class Text
  include Magick

  FONT_DIRECTORIES = ["/usr/share/fonts"]

  attr_reader :draw

  private

  def initialize(text, font_path=nil)
    @text = text

    # setup the draw
    @draw = Draw.new
    @draw.font = font_path || Text.available_fonts.sample
    @draw.gravity = CenterGravity
    @draw.pointsize = 128
  end

  def create_image
    # calculate and store the image dimensions
    dimensions = @draw.get_type_metrics @text
    @x = dimensions.width.ceil 
    @y = dimensions.height.ceil

    # create the image and draw text
    @image  = Image.new(@x, @y) { self.background_color = 'white' }
    @draw.annotate(@image, *[0]*4, @text)

    @image
  end

  # checks if a point is already in the points ary
  # aka if it has already been used and also if a point is surrounded
  # by too many other black points
  def point_invalid?(x,y)
    # white points are always invalid
    return true if @matrix[x,y] == :white

    # point already taken
    return true if @points.any? { |point| point == [x,y] }

    # if not already taken border points are always valid
    return false if x == 0 or y == 0 or x == @x or y == @y

    # if all non-diagonal neighbours are black, the point must be invalid
    neighbours = find_direct_neighbours(x,y)
    return true if neighbours.count == 4 and neighbours.all? { |neighbour| @matrix[*neighbour] == :black }

    # point is valid
    false
  end

  def find_direct_neighbours(x,y)
    x_min = [x-1,  0].max
    x_max = [x+1, @x].min

    y_min = [y-1,  0].max
    y_max = [y+1, @y].min

    [
      [x_min, y    ],
      [x_max, y    ],
      [x    , y_max],
      [x    , y_min]
    ].uniq - [[x,y]]
  end

  # finds next point in chain from current point
  def find_next_point(current)
    # 8 vectors turned counter-clockwise 45 degrees each
    vecs = [
      Vector[-1, 0],
      Vector[-1,-1],
      Vector[ 0,-1],
      Vector[ 1,-1],
      Vector[ 1, 0],
      Vector[ 1, 1],
      Vector[ 0, 1],
      Vector[-1, 1],
    ]

    # color of the last pixel
    last_color = @matrix[*(Vector[*current]+vecs.last).to_a]

    # turn the vector and find each which touches a white pixel
    touchy_vecs = vecs.map.with_index do |vec,i|
      current_color = @matrix[*(Vector[*current]+vec).to_a]
      color_changed = current_color != last_color
      last_color = current_color

      # return a vec or nil
      if color_changed
        # return the black point of the two touching the borderline
        if current_color == :black
          vec
        else
          # the one before vec, if i==0 the last one is the one before
          i-1 >= 0 ? vecs[i-1] : vecs.last
        end
      end
    end

    #remove nil(s) and duplicates
    touchy_vecs.compact!
    touchy_vecs.uniq!

    # possible next points
    touchy_points = touchy_vecs.map { |vec| (Vector[*current] + vec).to_a }

    # remove the invalid ones
    touchy_points.delete_if { |point| point_invalid? *point }

    # return the next point or nil
    touchy_points[0]
  end

  # starting with point(x,y), try to create a path (or chain)
  # until the starting point is reached again
  def create_pixel_chain(x,y)
    # can't create a chain if the point is invalid
    return if point_invalid?(x,y)

    # create a new ary in the paths ary
    @paths << []

    # setup state
    current_point = [x,y]

    while current_point
      # add the point to the points array
      @points << current_point

      # add the index of the last point in points aka current_point to faces
      @paths.last << @points.count - 1

      # try to find next point (nil if none was found)
      current_point = find_next_point(current_point)
    end
  end

  # aligns the text to the bottom-left corner of the first quadrant
  def align_points
    x_min = @points.map { |x,_| x }.min
    y_min = @points.map { |_,y| y }.min

    @points.map! { |x,y| [x-x_min, y-y_min] }
  end

  public
  def to_openscad
    @points = []
    @paths  = []

    # draw an image of the text and create a matrix from its pixels
    @matrix = create_image.pixel_matrix

    # go through each point aka pixel to make sure it gets used once
    # and try to retrace the letters
    @matrix.each_with_index do |_,x,y|
      create_pixel_chain(x,y)
    end

    # align them!
    align_points

    # finished woop woop
    "polygon(points=#{@points.to_s}, paths=#{@paths.to_s});"
  end

=begin !!just for debugging!!
  def debug_output
    out = @paths.map.with_index do |chain,i|
      s = ""
      s << '# ' if i != 0

      chain.each { |p_i| s << "translate(#{@points[p_i].to_s}) cube(1);\n" }
      s
    end

    out.each { |o| puts o, "/"*30 }
    exit
  end
=end

  def self.available_fonts
    FONT_DIRECTORIES.map do |dir|
      Dir[dir + "/**/*.ttf"]
    end.flatten!
  end
end

