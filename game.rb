

module GetKey
  @use_stty = begin
    require 'Win32API'
    false
  rescue LoadError
    # Use Unix way
   true
  end

  def self.getkey
    if @use_stty
      system('stty raw -echo') # => Raw mode, no echo
      char = (STDIN.read_nonblock(1).ord rescue nil)
      system('stty -raw echo') # => Reset terminal mode
      return char
    else
      return Win32API.new('crtdll', '_kbhit', [  ], 'I').Call.zero? ? nil : Win32API.new('crtdll', '_getch', [  ], 'L').Call
    end
  end
end

class Game

def border_row
  2.times do
    puts '|||===========================================================|||'
  end
end

def bottom_row
  '|||-----------------------------------------------------------|||'
end

def virtual_board
  @virtual_board ||= initialize_virtual_board
end

def head_coords()
  @head_coords ||= init_head_coords
end

def init_head_coords
  head = coords
  head[y] = 6
  head[x] = 10
  head
end

def tail_coords()
  @tail_coords ||= init_tail_coords
end

def init_tail_coords
  tail = coords
  tail[y] = 10
  tail[x] = 10
  tail
end

def x
  1
end

def y
  0
end

def coords
  [0, 0]
end

def build_snake(board)
  board[head_coords[y]][head_coords[x]] = snake_head
  board[7][10] = snake_body
  board[8][10] = snake_body
  board[9][10] = snake_body
  board[tail_coords[y]][tail_coords[x]] = snake_tail
  snake_directions
end

def snake_body
  '88'
end

def snake_head
  "/\\"
end

def snake_tail
  "\\/"
end

def initialize_virtual_board
  container = []
  (14.times { container.push(Array.new(20) { blank_space }) })
  build_snake(container)
  container
end

def board_row(y)
  print '|||'
  20.times do |x|
    print virtual_board[y][x]

    print '|' unless x == 19
  end
  print '|||'
  print "\n"
end

def blank_space
  '  '
end

def play
  puts
  border_row
  14.times do |index|
    board_row index
    puts bottom_row unless index == 13
  end
  border_row
  puts
end

def game_over
  puts
  border_row

  14.times do |index|
    puts '    GAME OVER     '
  end

  border_row
  puts
end

def direction
  @direction ||= :up
end

def insert(space, y, x)
  virtual_board[y][x] = space
end

def snake_directions
  @snake_directions ||= [:up, :up, :up]
end

def move_snake
  case direction
  when :up
    @head_coords[y] = head_coords[y] - 1
  when :left
    @head_coords[x] = head_coords[x] - 1
  when :down
    @head_coords[y] = head_coords[y] + 1
  when :right
    @head_coords[x] = head_coords[x] + 1
  end
  find_next_tail_coords
  @snake_directions.push(direction)
end

def snake_length
  @snake_length ||= 3
end

def find_next_tail_coords
  direction =if snake_directions.size > snake_length
              @snake_directions.shift
            else
              snake_directions[0]
            end

  case direction
  when :up
    @tail_coords[y] = tail_coords[y] - 1
  when :left
    @tail_coords[x] = tail_coords[x] - 1
  when :down
    @tail_coords[y] = tail_coords[y] + 1
  when :right
    @tail_coords[x] = tail_coords[x] + 1
  end
end

def next_head_space
  virtual_board[head_coords[y]][head_coords[x]]
end

def out_of_bounds
  @head_coords[y] < 0 ||
    @head_coords[y] > 13 ||
    @head_coords[x] < 0 ||
    @head_coords[x] > 19 ||
    next_head_space == snake_body ||
    next_head_space == snake_tail
end

def feed_snake(current_board)
  if next_head_space == food
    @snake_length += 1
    drop_food current_board
  else
    insert(snake_tail, tail_coords[y], tail_coords[x])
  end
end

def board_width_range
  @board_width = (1..20)
end

def board_height_range
   @board_height = (1..14)
end

def food
  '()'
end

def drop_food(current_board)
  y = board_width_range.to_a.sample
  x = board_height_range.to_a.sample
  next_food_spot = @virtual_board[y][x]

  if next_food_spot == snake_body || next_food_spot == snake_tail || next_food_spot == snake_head
    drop_food current_board
  else
    insert(food, y, x)
  end
end

def initialize_game
  board = virtual_board
  drop_food board
end

def start
  initialize_game

  while true do

    k = GetKey.getkey

    case k
    when 106
      @direction = :down
    when 104 || 91
      @direction = :left
    when 107 || 27
      @direction = :up
    when 108
      @direction = :right
    end

    puts "Key pressed: #{k.inspect}"

    play
    sleep(0.15)
    insert(snake_body, head_coords[y], head_coords[x])
    insert(blank_space, tail_coords[y], tail_coords[x])

    move_snake

    if out_of_bounds
      game_over
      return
    else
      feed_snake virtual_board
      insert(snake_head, head_coords[y], head_coords[x])
    end
  end
end
end

Game.new.start
