require_relative 'miscellaneous.rb'

class Piece
  include Miscellaneous
  attr_reader :color, :token, :pos

  def initialize(color, pos)
    @color = color
    @pos = pos
    @moves = 0
    @token = nil
  end

  def increment_move
    @moves += 1
  end

  def set_pos(pos)
    @pos = pos
  end

  def to_s
    @token
  end
end