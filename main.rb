require_relative 'lib/board.rb'
path = "./saved_game.yaml"
chess = Board.new

if File.exist?(path)
  f = File.read(path)
  chess.unserialize(f)
  puts "Saved game loaded successfully!"
end

chess.start

if chess.on_game?
  File.open(path, "w") do |f|
    f.write(chess.serialize)
  end
  puts "Game saved successfully!"
elsif File.exist?(path)
  File.delete(path)
end
