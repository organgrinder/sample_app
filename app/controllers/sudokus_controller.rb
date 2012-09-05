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
    @sudoku.update_attributes(params[:sudoku])
    @sudoku.apply_rules
    render 'sudokus/solver'
    @sudoku.save
    #saving after render b/c solver reverts the +10 back so only 1 number appears red each time
  end
  
end
