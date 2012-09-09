class SudokusController < ApplicationController
  
  def new
    @sudoku = Sudoku.new
  end
  
  def create
    @sudoku = Sudoku.new(params[:sudoku])
    @sudoku.fill_in_grid(params[:commit])
    @sudoku.save
    render 'sudokus/solver'
  end
  
  def show
    @sudoku = Sudoku.find(params[:id])
    @rules_used=[]
    if params[:solve_this_many]=="all"
      while (!@sudoku.solved) 
        rule=@sudoku.apply_rules
        if !rule # apply_rules returned false means rules didn't work
          break
        else
          @rules_used.push(rule) unless @rules_used.include?(rule)
        end
      end
    else    
      params[:solve_this_many].to_i.times do
        rule=@sudoku.apply_rules
        if !rule # apply_rules returned false means rules didn't work
          break
        else
          @rules_used.push(rule) unless @rules_used.include?(rule)
        end
      end
    end
    
    render 'sudokus/solver'
    @sudoku.clear_updated_last
    @sudoku.save

  end
  
  def update
    @sudoku = Sudoku.find(params[:id])
    @sudoku.big_grid=Array.new(81)
    81.times do |i|
      if (params[i.to_s].to_i)
        params[i.to_s].to_i > 0 ? @sudoku.big_grid[i]={ value: params[i.to_s].to_i } : @sudoku.big_grid[i]={}
      end
    end
    @sudoku.save
    render 'sudokus/solver'
  end
  
end
