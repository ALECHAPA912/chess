class Node
  attr_reader :last, :value
  def initialize(last, value)
    @last = last
    @value = value
  end
end