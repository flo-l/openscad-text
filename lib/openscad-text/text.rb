class Text
  # This yields 8 vectors turned counter-clockwise 45 degrees each
  class TurnVector
    include Enumerable
    VECTORS = [
      Vector[-1, 0],
      Vector[-1,-1],
      Vector[ 0,-1],
      Vector[ 1,-1],
      Vector[ 1, 0],
      Vector[ 1, 1],
      Vector[ 0, 1],
      Vector[-1, 1],
    ].freeze

    def initialize(state)
      @state = VECTORS.find_index Vector[*state]
    end

    def each
      VECTORS.length.times do
        @state = 0 if @state >= VECTORS.length
        yield VECTORS[@state]
        @state += 1
      end
    end
  end
end

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
    @columns = dimensions.width.ceil 
    @rows    = dimensions.height.ceil

    # create the image and draw text
    @image  = Image.new(@columns, @rows) { self.background_color = 'white' }
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
    return false if x == 0 or y == 0

    # if all non-diagonal neighbours are black, the point must be invalid
    neighbours = find_direct_neighbours(x,y)
    return true if neighbours.count == 4 and neighbours.all? { |neighbour| @matrix[*neighbour] == :black }

    # point is valid
    false
  end

  def find_direct_neighbours(x,y)
    x_min = [x-1,        0].max
    x_max = [x+1, @columns].min

    y_min = [y-1,        0].max
    y_max = [y+1, @rows   ].min

    [
      [x_min, y    ],
      [x_max, y    ],
      [x    , y_max],
      [x    , y_min]
    ].uniq - [[x,y]]
  end

  def find_next_point(last, current)
    state = Vector[*last] - Vector[*current]
    vecs  = TurnVector.new(state).to_a

    # are we going in the wrong direction?
    vecs.reverse! if @matrix[*(Vector[*current]+vecs[1]).to_a] == :black

    # vector from the current to the next point
    vec_next = vecs.detect { |vec| @matrix[*(Vector[*current]+vec).to_a] == :black }

    # return the next point
    (Vector[*current] + vec_next).to_a
  end

  # finds one possible last point from current_point
  def find_last_point(current_point)
    t = TurnVector.new([-1,-1]).to_a

    # ary with bools true for :black, false for :white
    is_black = t.map { |vec| @matrix[*(Vector[*current_point]+vec).to_a] == :black }

    possible_vecs = []
    is_black.each_cons(2).with_index  do |cons,i|
      a,b = cons
      if  ! a and b
        possible_vecs << t[i+1]
      elsif a and ! b
        possible_vecs << t[i]
      end
    end

    # corner cases for [false, false, true, true]
    #              and [true, true, false, false]
    # then the first/last one is also a border point
    possible_vecs << t.first if ! is_black.first and   is_black.last
    possible_vecs << t.last  if   is_black.first and ! is_black.last

    # return last point
    (possible_vecs.first + Vector[*current_point]).to_a
  end

  # starting with point(x,y), try to create a path (or chain)
  # until the starting point is reached again
  def create_pixel_chain(x,y)
    # can't create a chain if the point is invalid
    return if point_invalid?(x,y)

    # create a new ary in the faces ary
    @paths << []

    # setup state
    current_point = [x,y]
    last_point = find_last_point(current_point)

    while current_point
      # add the point to the points array
      @points << current_point

      # add the index of the last point in points aka current_point to faces
      @paths.last << @points.count - 1

      # try to find next point
      next_point = find_next_point(last_point, current_point)

      # stop then
      if point_invalid? *next_point
        #p last_point, current_point, next_point if false and @points.count == 68
        break
      else
        last_point = current_point
        current_point = next_point
      end
    end
  end

  public
  def to_openscad
    @points = []
    @paths  = []

    # create a matrix from pixels
    @matrix = create_image.pixel_matrix

    # go through each point aka pixel to make sure it gets used once
    @matrix.each_with_index do |_,x,y|
      create_pixel_chain(x,y)
    end

    # finished woop woop
    "polygon(points=#{@points.to_s}, paths=#{@paths.to_s});"
  end

  def self.available_fonts
    FONT_DIRECTORIES.map do |dir|
      Dir[dir + "/**/*.ttf"]
    end.flatten!
  end
end

