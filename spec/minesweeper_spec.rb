require "spec_helper"

describe Minesweeper do
  it "has a version number" do
    expect(Minesweeper::VERSION).not_to be nil
  end

  it "can initialize a board" do
    expect(Minesweeper::Board.new).not_to be nil
  end

  it "initializes a default board of size 9" do
    expect(Minesweeper::Board.new.board.size).to eq 9
  end

  it "initializes a default board with 10 mines" do
    board = Minesweeper::Board.new
    expect(board.board.flatten.count(&:mine)).to eq 10
  end

  it "new boards do not show as complete" do
    expect(Minesweeper::Board.new.complete?).to be false
  end

  it "finished boards show as complete" do
    board = Minesweeper::Board.new
    board.board.each_index do |i|
      board.board[i].each_index do |j|
        board.board[i][j].revealed= true
      end
    end
    expect(board.complete?).to be true
  end

  it "explodes when you step on a mine" do
    board = Minesweeper::Board.new(9,10,Random.new(0))
    expect(board.board[5][4].mine).to be true
    expect do
      board.step(5,4)
    end.to raise_error(Minesweeper::MineSteppedOnException)
  end

  it "reveals tiles that do not contain a mine" do
    board = Minesweeper::Board.new(9,10,Random.new(0))
    board.step(4,8)
    expect(board.board[4][8].mine).to be false
    expect(board.board[4][8].revealed).to be true
  end

  it "reveals adjacent safe tiles recursively" do
    
  end

  it "can flag a tile as a mine" do
    board = Minesweeper::Board.new(9,10,Random.new(0))
    board.toggle_flag(4,8)
    expect(board.board[4][8].flagged).to be true
    expect(board.board[4][8].revealed).to be false
  end

  it "can unflag a flagged tile" do
    board = Minesweeper::Board.new(9,10,Random.new(0))
    board.toggle_flag(4,8)
    expect(board.board[4][8].flagged).to be true
    board.toggle_flag(4,8)
    expect(board.board[4][8].flagged).to be false
    expect(board.board[4][8].revealed).to be false
  end
end
