require_relative 'piece.rb'

class Rook < Piece
  def initialize(color, pos)
    super(color, pos)
    @token = @color == white_token ? white_rook : black_rook
  end

  def moves
    result = []
    (1..7).each do |move|
      result << [-move, 0]
      result << [0, -move]
      result << [0, move]
      result << [move, 0]
    end
    result
  end
end