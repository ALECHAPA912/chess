require_relative 'piece.rb'

class Bishop < Piece
  def initialize(color, pos)
    super(color, pos)
    @token = @color == white_token ? white_bishop : black_bishop
  end

  def moves
    result = []
    (1..7).each do |move|
      result << [move, move]
      result << [-move, -move]
      result << [-move, move]
      result << [move, -move]
    end
    result
  end
  
end