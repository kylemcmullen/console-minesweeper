module Minesweeper
  class Board

    attr_reader :board

    def initialize(board_size=9, mines = 10, rng=Random.new)
      total_tiles = board_size ** 2

      raise "too many mines for board (requested #{mines}, max is #{total_tiles}" if mines > total_tiles

      @board = Array.new(board_size) do
        Array.new(board_size) do
          Tile.new(false, false, false, 0)
        end
      end

      mines.times do
        i,j = rng.rand(1...total_tiles).divmod(board_size)
        mined_tile = @board[i][j]
        mined_tile.mine = true
      end

      # populate neighbors
      count = 0
      @board.each_with_index do |row, i|
        row.each_with_index do |row, j|
          tile = @board[i][j]
          tile_neighbors = []
          count += 1

          each_adjacent_tile(i,j) do |tile, _i, _j|
            @board[i][j].neighbors= @board[i][j].neighbors + 1 if tile.mine
          end

        end
      end
    end

    ##
    # Step on square (i,j)
    def step(i,j)
      tile = @board[i][j]

      tile.step
      reveal_safe_neighbors(i,j)
    end

    ##
    # Flag square (i,j) as a suspected mine
    def toggle_flag(i,j)
      @board[i][j].toggle_flag
    end

    ##
    # Print an ASCII representation of the board
    def print
      puts "|#{'-'*(2*@board.size-1)}|"
      @board.each do |row|
        puts "|#{row.map(&:pretty).join('|')}|"
      end
      puts "|#{'-'*(2*@board.size-1)}|"
    end

    ##
    # The game is over if all tiles are revealed, or flagged mines
    def complete?
      @board.each do |row|
        row.each do |tile|
          unless tile.revealed
            unless tile.mine && tile.flagged
              return false
            end
          end
        end
      end

      return true
    end

    private
    def each_adjacent_tile(i,j)
      [-1, 0, 1].each do |vertical_offset|
        [-1, 0, 1].each do |horizontal_offset|
          _i = i+vertical_offset
          _j = j+horizontal_offset

          next if _i == i && _j == j
          next if _i < 0 || _i >= @board.size
          next if _j < 0 || _j >= @board.size

          yield @board[_i][_j], _i, _j
        end
      end
    end

    def reveal_safe_neighbors(i,j)
      tile = @board[i][j]
      # if 0 adjacent mines, reveal adjacent tiles
      if tile.neighbors == 0
        each_adjacent_tile(i,j) do |adjacent_tile, _i, _j|
          next if adjacent_tile.revealed # already visited this tile

          # it should be safe to step here, since no adjacent tile should have a mine...
          adjacent_tile.step

          # recurse if this tile is safe
          if adjacent_tile.neighbors == 0
            reveal_safe_neighbors(_i, _j)
          end
        end
      end
    end

  end

  Tile = Struct.new(:mine, :flagged, :revealed, :neighbors) do
    def toggle_flag
      self.flagged= !flagged
    end

    def step
      self.revealed= true
      if mine
        raise MineSteppedOnException.new
      end
    end

    def pretty
      if revealed && !mine
        neighbors.to_s
      elsif revealed && mine
        '*'
      elsif flagged
        'F'
      else
        '^'
      end
    end
  end

  class MineSteppedOnException < Exception

  end
end