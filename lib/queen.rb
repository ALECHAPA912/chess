require_relative 'piece.rb'

class Queen < Piece
  def initialize(color, pos)
    super(color, pos)
    @token = @color == white_token ? white_queen : black_queen
  end

  def moves
    result = []
    (1..7).each do |move|
      result << [-move, 0]
      result << [0, -move]
      result << [0, move]
      result << [move, 0]
      result << [move, move]
      result << [-move, -move]
      result << [-move, move]
      result << [move, -move]
    end
    result
  end
end