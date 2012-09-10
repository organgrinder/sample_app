class SudokusController < ApplicationController
  
  def new
    @sudoku = Sudoku.new
  end

  def create
    @sudoku = 
      case params[:create]
      when "original"
        Sudoku.createDefault(params[:sudoku])
      when "random"
        Sudoku.createRandom(params[:sudoku])
      else
        Sudoku.create(params[:sudoku])
      end

    if @sudoku.big_grid.nil?
      redirect_to edit_sudoku_path(@sudoku)
    else
      redirect_to sudoku_path(@sudoku)
    end
  end
  
  def edit
    @sudoku = Sudoku.find(params[:id])
  end
  
  def solve
    @sudoku = Sudoku.find(params[:id])
    rules_used = []
    locations_updated = []
    # try assigning both of these on 1 line 
    if params[:solve_this_many] == "all"
      until @sudoku.solved
        rule_results = @sudoku.apply_rules
        
        # apply_rules returned false means rules didn't work
        break unless rule_results
        
        rules_used.push(rule_results[:rule_text]) unless rules_used.include?(rule_results[:rule_text])
        locations_updated.push(rule_results[:location])
      end
    else    
      params[:solve_this_many].to_i.times do
        rule_results = @sudoku.apply_rules
        
        # apply_rules returned false means rules didn't work
        break unless rule_results
        
        rules_used.push(rule_results[:rule_text]) unless rules_used.include?(rule_results[:rule_text])
        locations_updated.push(rule_results[:location])
      end
    end
    
    @sudoku.save
    
    flash[:rules] = rules_used
    flash[:locations] = locations_updated
    
    redirect_to sudoku_path(@sudoku)
  end
  
  def show
    @sudoku = Sudoku.find(params[:id])
    
    @rules_used = flash[:rules] || []
    @locations_updated = flash[:locations] || []
    flash.delete(:rules)
    flash.delete(:locations)
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
    
    redirect_to sudoku_path(@sudoku)
  end
  
end
