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
  
  def show
    @sudoku = Sudoku.find(params[:id])
    
    if params[:solve_this_many]=="all"
      @sudoku.apply_rules while !@sudoku.solved
    else    
      params[:solve_this_many].to_i.times do
        @sudoku.apply_rules
      end
    end
    
    render 'sudokus/solver'
    @sudoku.clear_updated_last
    @sudoku.save

  end
  
end
