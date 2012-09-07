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
    @message = @sudoku.apply_rules
    
    render 'sudokus/solver'
    @sudoku.clear_updated_last
    @sudoku.save

  end
  
end
