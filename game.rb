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
  what = coords
  what[y] = 6
  what[x] = 10
  what
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
  board[10][10] = snake_tail
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
  puts bottom_row
  end
  border_row
  puts
end


def insert(space, y, x)
  virtual_board[y][x] = space
end

index = 0

while true do
  index += 1
  play
  sleep(0.22)
  insert(snake_body, head_coords[y], head_coords[x])
  @head_coords[y] = head_coords[y] - 1
  insert(snake_head, head_coords[y], head_coords[x])
end



