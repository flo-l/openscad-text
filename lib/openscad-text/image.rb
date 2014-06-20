# Extend the Magick::Image class with a pixel_matrix method which 
# returns a matrix with pixels represented by :black and :white
class Magick::Image
  # creates a matrix of the pixels, exchanging them
  # with :black and :white symbol objects
  def pixel_matrix
    # Because I messed things a little up the image needs to be flipped,
    # in order to render the text not mirror-inverted
    flip!

    pixels = []
    each_pixel do |pixel,_,row|
      # black pixel -> :black, white pixel -> :white
      if pixel.to_color == 'white'
        pixel = :white
      else
        pixel = :black
      end

      # create a 2-dimensional array
      if pixels[row]
        pixels[row] << pixel
      else
        pixels[row] = [pixel]
      end
    end

    Matrix[*pixels].transpose
  end
end
