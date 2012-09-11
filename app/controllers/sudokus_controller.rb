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
      flash[:just_created] = true
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

    if params[:solve_this_many] == "all"
      until @sudoku.solved
        rule_results = @sudoku.apply_rules
        
        # apply_rules returned false means rules didn't work
        break unless rule_results
        
        rules_used.push(rule_results[:rule_text]) unless rules_used.include?(rule_results[:rule_text])
        rule_results[:locations].each { |location| locations_updated.push(location) }
        # locations_updated.push(rule_results[:location])
      end
    else    
      params[:solve_this_many].to_i.times do
        rule_results = @sudoku.apply_rules
        
        # apply_rules returned false means rules didn't work
        break unless rule_results
        
        rules_used.push(rule_results[:rule_text]) unless rules_used.include?(rule_results[:rule_text])
        rule_results[:locations].each { |location| locations_updated.push(location) }
        # locations_updated.push(rule_results[:location])
      end
    end
    
    @sudoku.save
    
    flash[:rules] = rules_used
    flash[:locations] = locations_updated
    
    redirect_to sudoku_path(@sudoku)
  end
  
  def show
    @sudoku = Sudoku.find(params[:id])
    
    @just_created = flash[:just_created]
    @rules_used = flash[:rules] || []
    @locations_updated = flash[:locations] || []
    flash.delete(:just_created)
    flash.delete(:rules)
    flash.delete(:locations)
  end
  
  def update
    @sudoku = Sudoku.find(params[:id])
    @sudoku.big_grid=[]
    81.times do |i|
      if (params[i.to_s].to_i)
        params[i.to_s].to_i > 0 ? @sudoku.big_grid[i]={ value: params[i.to_s].to_i } : @sudoku.big_grid[i]={}
      end
      
      # should find a way to not have to repeat these 2 lines - they are also in massage_grid in sudoku.rb
      @sudoku.big_grid[i][:location] = i
      @sudoku.big_grid[i][:possibilities] = []
    end
    
    @sudoku.save
    
    flash[:just_created] = true
    redirect_to sudoku_path(@sudoku)
  end
  
end
