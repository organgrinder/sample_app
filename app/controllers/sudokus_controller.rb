class SudokusController < ApplicationController
  
  def new
    @sudoku = Sudoku.new
  end
  
  def create
    @sudoku = Sudoku.new(params[:sudoku])
    @sudoku.fill_in_grid
    @sudoku.save
    render 'sudokus/solver'
  end
  
  def update
    @sudoku = Sudoku.find(params[:id])
    @sudoku.apply_rules
    @sudoku.save
    render 'sudokus/solver'

  end
  
end
