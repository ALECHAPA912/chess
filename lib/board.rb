require_relative 'miscellaneous.rb'
require_relative 'king.rb'
require_relative 'queen.rb'
require_relative 'rook.rb'
require_relative 'bishop.rb'
require_relative 'knight.rb'
require_relative 'pawn.rb'
require_relative 'node.rb'
require_relative 'serializable.rb'
require 'set'

class Board
  include Miscellaneous
  include Serializable

  def initialize
    @board = nil
    @current_player = 0
    @gamemode = nil
    @sp_team = nil
    @players = [white_token, black_token]
    @board_status = :in_menu
  end

  def on_game?
    @board_status == :playing
  end

  def on_menu?
    @board_status == :on_menu
  end

  def start
    loop do
      if @board
        @gamemode == 0 ? single_player : multi_player
      else
        clear_screen
        greetings
        case game_mode
          when "1"
          break if single_player == "exit"
          when "2"
          break if multi_player == "exit"
          when "exit"
          break
        end
      end
      break if exit?
      reset_board
    end
  end

  def game_mode
    two_options_question("Choose your game mode:\n- Insert '1' for Singleplayer (vs Machine)\n- Insert '2' for Multiplayer (PvP)\n- Insert 'exit' for exit")
  end

  def exit?
    two_options_question("--------------------------------------\n-Insert '1' to start a new game\n-Insert '2' to save and exit") == "1" ? false : true
  end

  def two_options_question(question)
    puts question
    selection = gets.chomp
    until selection.match?(/\A[12]\z/) || selection == "exit" 
      puts "Invalid input! Please insert '1', '2' or 'exit':"
      selection = gets.chomp
    end
    selection
  end

  def print_board
    puts "┌───┬───┬───┬───┬───┬───┬───┬───┬───┐"
    7.downto(0) do |row|
      (0..7).each do |col|
        result = @board[col][row].nil? ? "   │" : " #{@board[col][row]} │"
        print "│ #{(row)} │" if col == 0
        print result
      end
      print "\n├───┼───┼───┼───┼───┼───┼───┼───┼───┤\n"
    end
    print "│   │"
    (0..7).each {|index| print " #{find_letter(index)} │"}
    print "\n└───┴───┴───┴───┴───┴───┴───┴───┴───┘\n"
  end

  def single_player
    @gamemode = 0 
    create_board if @board.nil?
    @sp_team = team_selection if @sp_team.nil?
    @board_status = :playing
    until game_over?
      begin
        clear_screen
        print_board
        play = @current_player == @sp_team ? do_a_play : machine_plays
        return if play == "exit"
      end until play
      switch_player
    end
  end

  def clear_screen
    Gem.win_platform? ? system("cls") : system("clear") 
  end

  def team_selection
    selection = two_options_question("Select your team:\n >Insert 1 for White #{white_token}.\n  >Insert 2 for Black #{black_token}.")
    selection == 'exit' ? selection : (selection.to_i) - 1
  end

  def machine_plays
    color = @players[@current_player]
    piece = get_team(color).reject {|piece| all_legal_moves(piece, color).empty?}.sample
    random_move = all_legal_moves(piece, color).sample
    target_pos = sum_coords(piece.pos, random_move)
    put_piece(piece, target_pos)
  end

  def multi_player
    @gamemode = 1 
    create_board if @board.nil?
    @board_status = :playing
    until game_over?
      begin
        clear_screen
        print_board
        play = do_a_play
        return if play == "exit"
        clear_screen
      end until play
      switch_player
    end
  end

  def checkmate?(color)
    if check?(color) && !has_legal_moves?(color)
      switch_player
      puts "CHECK-MATE!!! CONGRATULATIONS PLAYER #{@players[@current_player]}, YOU WON!!!"
      true
    else 
      false
    end
  end

  def undo_move(piece, piece_last_pos, target, target_pos)
    put_piece(piece, piece_last_pos)
    put_piece(target, target_pos)
  end

  def check?(color)
    enemies = get_enemies(color)
    king = get_king(color)
    return enemies.any? { |enemy| in_range?(enemy, king) }
  end

  def in_range?(piece, goal_piece)
    return all_pseudo_legal_moves(piece).any? { |move| goal_piece.pos == sum_coords(piece.pos, move) }
  end

  def all_piece_moves(piece)
    piece.is_a?(Pawn) ? piece.moves + piece.capture : piece.moves
  end

  def all_pseudo_legal_moves(piece)
    all_piece_moves(piece).select { |move| is_pseudo_legal_move?(piece, move) }
  end

  def is_pseudo_legal_move?(piece, move) 
    #verifica si el movimiento de la pieza argumento puede moverse libremente
    #evalua solamente si el movimiento se encuentra dentro del tablero y si la pieza
    #tiene espacio para moverse y o atacar
    target_pos = sum_coords(move, piece.pos)
    return false if out_of_bounds?(target_pos)
    col, row = target_pos[0], target_pos[1]
    target = @board[col][row]
    return false if target&.color == piece.color
    if piece.is_a?(Pawn) && target.is_a?(Piece)
      return true if piece.capture.include?(move)
      return false
    end
    return false unless piece.moves.include?(move)
    if !piece.is_a?(Knight)
      return false unless legal_path?(piece, target_pos)
    end
    true
  end

  def all_legal_moves(piece, color)
    all_piece_moves(piece).select { |move| is_legal_move?(piece, move, color) }
  end

  def is_legal_move?(piece, move, color)
    # chequeamos si el movimiento es pseudolegal para despues simular el 
    # movimiento ingresado para definir si el movimiento es completamente legal
    if is_pseudo_legal_move?(piece, move)
      target_pos = sum_coords(piece.pos, move)
      target = @board[target_pos[0]][target_pos[1]] #valor de la ubicacion del posible movimiento
      return false if target.is_a?(King)
      piece_last_pos = piece.pos #ultima posicion de la pieza
      put_piece(piece, target_pos) #simula el movimiento
      result = check?(color) #chequea si hay jaque
      undo_move(piece, piece_last_pos, target, target_pos) #borra el movimiento simulado
      return false if result #retorna falso si hay jaque
      true
    else
      false
    end
  end

  def switch_player
    @current_player = @current_player == 0 ? 1 : 0
  end

  def game_over?
    checkmate?(@players[@current_player]) || stalemate?(@players[@current_player])
  end

  def stalemate?(color)
    if !check?(color) && !has_legal_moves?(color)
      puts "STALEMATE! IT'S A DRAW ;("
      true
    else 
      false
    end
  end

  def has_legal_moves?(color)
    get_team(color).any? { |piece| all_legal_moves(piece, color).any? }
  end

  def get_all_pieces
    #el compact convierte a board en un solo array y el compact elimina todas las casillas vacias (los nil)
    @board.flatten.compact
  end

  def get_enemies(color)
    get_all_pieces.select { |piece| piece.color != color } 
  end

  def get_team(color)
    get_all_pieces.select { |piece| piece.color == color }
  end

  def get_king(color)
    get_team(color).each { |piece| return piece if piece.is_a?(King) }
  end

  def do_a_play
    puts "It's your turn Player #{@players[@current_player]}!"
    selection = select_piece
    until selection do
      return selection if selection == "exit"
      selection = select_piece
    end
    return selection if selection == "exit"
    plays = move_piece(selection)
    until plays
      return plays if plays == "exit"
      plays = move_piece(selection)
    end
    return nil if plays == "change"
    plays
  end

  def select_piece
    puts "Select the piece you want to move! (Input coords: First letter, then number; e.g: 'A1').\nInsert 'exit' to exit and save your game."
    coords = verify_input(gets.chomp)
    until coords do
      coords = verify_input(gets.chomp)
    end
    return coords if coords == "exit"
    selection = @board[coords[0]][coords[1]]
    validate_piece_selection(selection)
  end

  def validate_piece_selection(piece)
    if piece
      if piece.color == @players[@current_player]
        puts "#{piece} selected!" 
        return piece
      else
        puts "You're not allowed to select this piece, try with other one!"
      end
    else
      puts "You selected a blank space! Try with other coords!"
    end
    nil
  end

  def verify_input(input)
    return input if input == "exit"
    clean_input = input.gsub(/\s+/, "").upcase
    if clean_input.match?(/\A[A-H][0-7]\z/)
      clean_input.split('')
      [find_column(clean_input[0]), clean_input[1].to_i]
    else
      puts "Incorrect input, please select a valid coord. (First letter, then number; e.g: 'A1')"
      nil
    end
  end

  def move_piece(piece)
    puts "Select the position you want to move your #{piece}! (Input coords: First letter, then number; e.g: 'A1')\nTo change your selected piece insert 'change'."
    new_pos = nil
    until new_pos do
      input = gets.chomp
      return input if input == "change" || input == "exit"
      new_pos = verify_input(input)
    end
    clean_move = subtract_coords(new_pos, piece.pos)
    if is_legal_move?(piece, clean_move, @players[@current_player]) 
      piece.increment_move
      put_piece(piece, new_pos)
    else
      puts "ILEGAL MOVE!" 
      nil
    end
  end

  def put_piece(piece, new_pos)
    return if piece.nil?
    clear_pos(piece)
    piece.set_pos(new_pos)
    col, row = new_pos[0], new_pos[1]
    @board[col][row] = piece
  end

  def clear_pos(piece)
    return if piece.nil?
    clear_col, clear_row = piece.pos[0], piece.pos[1]
    @board[clear_col][clear_row] = nil
  end

  def out_of_bounds?(pos)
    !(pos[0].between?(0,7) && pos[1].between?(0,7))
  end

  def sum_coords(coord1, coord2)
    [coord1[0]+coord2[0] , coord1[1]+coord2[1]]
  end

  def no_obstacles?(piece, goal_pos, node_path)
    return false if node_path.nil?
    current_node = node_path
    until current_node.nil?
      col, row = current_node.value[0], current_node.value[1]
      if @board[col][row].is_a?(Piece) && @board[col][row] != piece && current_node.value != goal_pos
        return false 
      end
      current_node = current_node.last
    end
    true
  end

  def find_shortest_path(piece, goal_pos)
    single_moves = [[1,0],[-1,0],[0,1],[0,-1],[1,1],[-1,1],[1,-1],[-1,-1]]
    to_visit = [Node.new(nil, piece.pos)]
    visited = Set.new([piece.pos])
    until to_visit.empty? do
      current_node = to_visit.shift
      single_moves.each do |moves|
        next_move = sum_coords(current_node.value, moves)
        return current_node if current_node.value == goal_pos
        next if out_of_bounds?(next_move)
        next if visited.include?(next_move)
        visited.add(next_move)
        to_visit << Node.new(current_node, next_move)
      end
    end
    nil
  end

  def legal_path?(piece, target_pos)
    no_obstacles?(piece, target_pos, find_shortest_path(piece, target_pos))
  end
  
  def subtract_coords(coord1, coord2)
    [(coord1[0] - coord2[0]) , (coord1[1] - coord2[1])]
  end

  def find_column(letter)
    letters = ('A'..'H').to_a
    letters.each_with_index {|char, index| return index if char == letter.upcase}
  end

  def find_letter(index)
    letters = ('A'..'H').to_a
    letters[index]
  end

  def greetings
    puts "WELCOME TO ALEJANDRO'S CHESS GAME! #{white_knight} #{black_king}"
  end

  def create_board
    @board = Array.new(8) { Array.new(8, nil) }
    @current_player = 0
    @board_status = :playing
    [0, 7].each do |row|
      token = (row == 0 ? white_token : black_token)
      @board[4][row] = King.new(token, [4, row])
      @board[3][row] = Queen.new(token, [3, row])
      [2, 5].each { |col| @board[col][row] = Bishop.new(token, [col, row]) }
      [1, 6].each { |col| @board[col][row] = Knight.new(token, [col, row]) } 
      [0, 7].each { |col| @board[col][row] = Rook.new(token, [col, row]) }
    end
    [1, 6].each do |row|
      token = (row == 1 ? white_token : black_token)
      (0..7).each do |col|
        @board[col][row] = Pawn.new(token, [col, row])
      end
    end
  end

  def reset_board
    @board = nil
    @current_player = 0
    @gamemode = nil
    @sp_team = nil
    @board_status = :in_menu
  end
end
