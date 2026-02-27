require_relative 'piece.rb'

class King < Piece
  def initialize(color, pos)
    super(color, pos)
    @token = @color == white_token ? white_king : black_king
  end

  def moves
    [[1, 0], [0, 1], [-1, 0], [0, -1], [1, -1], [1, 1], [-1, -1], [-1, 1]]
  end
end