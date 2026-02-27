require_relative 'piece.rb'

class Knight < Piece
  def initialize(color, pos)
    super(color, pos)
    @token = @color == white_token ? white_knight : black_knight
  end

  def moves
    [[1,2],[2,1],[-1,2],[-2,1],[1,-2],[2,-1],[-1,-2],[-2,-1]]
  end
end