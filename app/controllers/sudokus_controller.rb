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
    
    @arra=Array.new(5)
    5.times do |i|
      @arra[i]=Number.new
      @arra[i].value=i
    end

    @number=Number.new
    @number.value=28
    render 'sudokus/solver'


  end
  
end
