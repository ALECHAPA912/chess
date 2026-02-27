require_relative 'piece.rb'

class Pawn < Piece
  def initialize(color, pos)
    super(color, pos)
    @token = @color == white_token ? white_pawn : black_pawn
  end

  def moves
    if @color == "⚪"
      if @moves > 0
        [[0, 1]]
      else
        [[0, 1], [0, 2]]
      end
    else
      if @moves > 0
        [[0, -1]] 
      else
        [[0, -1], [0, -2]]
      end
    end
  end

  def capture
    if @color == "⚪"
      [[1, 1], [-1, 1]]
    else
      [[1, -1], [-1, -1]]
    end
  end
end