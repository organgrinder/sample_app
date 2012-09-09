class Sudoku < ActiveRecord::Base

  attr_accessible :content, :big_grid
  serialize :big_grid
  
  def rule_1

    # fill in numbers in cubes where numbers can go in just 1 place
    
    9.times do |number_index|
      number=number_index+1
      winner_cube_number=-1
      9.times do |current_cube_number|
        if (all_possible_spots_in_cube(number,current_cube_number)==1)
          winner_cube_number=current_cube_number
          winner_location=first_possible_spot_in_cube(number,winner_cube_number)
          big_grid[winner_location][:value]=number
          big_grid[winner_location][:updated_last]=true
          return "Rule 1:  Pick a 3x3 cube and pick a number.  If there 
          is only 1 spot in that cube where that number can go (based on numbers other numbers 
          filled in, but not possibilities recorded), fill it in."
        end
      end
    end
  return false
  end

  def solved
    return false if !self.big_grid
    self.big_grid.each do |item|
      return false if !item[:value]
    end
    return true
  end

  def clear_updated_last
    self.big_grid.each do |item|
      item[:updated_last]=false
    end
  end

  def first_possible_spot_in_cube(number,cube_number)
    locations_in_cube=locations_in_cube(cube_number)
    locations_in_cube.each do |location|
      return location if (can_go_in_spot(number,location))
    end
    return 81
  end
  
  def all_possible_spots_in_cube(number,cube_number)
    spots=0
    locations_in_cube=locations_in_cube(cube_number)
    locations_in_cube.each do |location|
      spots+=1 if (can_go_in_spot(number,location))
    end
    return spots
  end

  def can_go_in_spot(number, location)
    return !( column_by_location(location).include?(number) || 
              row_by_location(location).include?(number) ||
              cube_by_location(location).include?(number) ||
              big_grid[location][:value])
  end

  def locations_in_cube(number)
    start_location=cube_start_location(number)
    cube_locations=Array.new(9)
    9.times do |i|
      cube_locations[i]=start_location
      if (i%3==2) 
        start_location+=7
      else
        start_location+=1
      end
    end
    return cube_locations
  end

  def cube_by_location(location)
    return cube_by_number(0) if (location%9<3 && location<27)
    return cube_by_number(1) if (location%9>2 && location%9<6 && location<27)
    return cube_by_number(2) if (location%9>5 && location<27)
    return cube_by_number(3) if (location%9<3 && location>26 && location<54)
    return cube_by_number(4) if (location%9>2 && location%9<6 && location>26 && location<54)
    return cube_by_number(5) if (location%9>5 && location>26 && location<54)
    return cube_by_number(6) if (location%9<3 && location>53)
    return cube_by_number(7) if (location%9>2 && location%9<6 && location>53)
    return cube_by_number(8) if (location%9>5 && location>53)
  end

  def cube_by_number(number)
    start_location=cube_start_location(number)
    cube=Array.new(9)
    9.times do |i|
      cube[i]=big_grid[start_location][:value]
      if (i%3==2) 
        start_location+=7
      else
        start_location+=1
      end
    end
    return cube
  end
  
  def cube_objects_by_number(number)
    start_location=cube_start_location(number)
    cube=Array.new(9)
    9.times do |i|
      cube[i]=big_grid[start_location]
      if (i%3==2) 
        start_location+=7
      else
        start_location+=1
      end
    end
    return cube
  end
  
  def cube_start_location(number)
    start_location=0 if (number==0)
    start_location=3 if (number==1)
    start_location=6 if (number==2)
    start_location=27 if (number==3)
    start_location=30 if (number==4)
    start_location=33 if (number==5)
    start_location=54 if (number==6)
    start_location=57 if (number==7)
    start_location=60 if (number==8)
    return start_location
  end
  
  def row_by_number(number)
    return row_by_location(number*9)
  end
  
  def column_by_number(number)
    return column_by_location(number)
  end

  def row_by_location(location)
    start_location=location-location%9
    row=Array.new(9)
    9.times do |i|
      row[i]=big_grid[start_location][:value]
      start_location+=1
    end
    return row
  end

  def column_by_location(location)
    start_location=location%9
    column=Array.new(9)
    9.times do |i|
      column[i]=big_grid[start_location][:value]
      start_location+=9
    end
    return column
  end

  def rule_2
    return false
    
    # Pick a number and pick a cube.  If there are exactly 2 spots in the cube where that number can go, 
    # record them in as possibilities.
  end

  def rule_3
    return false
    
    # If a spot with a possibilty recorded has been filled in with a number, fill in the other spot where that 
    # number was listed as a possibility.  Erase the possibilities.
  end

  def rule_3
    return false
    
    # Pick a number and pick a cube.  If there is only spot in the cube where that number can go (considering
    # numbers filled in AND possibilities recorded), fill it in in that spot.
  end

  def apply_rules
    
    return rule_1 || rule_2
        
  end # apply_rules
  
  def fill_in_grid(puzzle)
    
    return if puzzle=="Create Your Own"

    self.big_grid=Array.new(81)

    if puzzle=="Original Puzzle"
      array_values=[0,4,3, 0,0,6, 0,0,0,
                   0,0,9, 2,1,0, 0,0,0,
                   0,6,8, 5,0,9, 2,0,3,
                   
                   5,0,0, 9,3,0, 1,0,0,
                   6,0,0, 0,7,0, 0,0,9,
                   0,0,4, 0,6,2, 0,0,8,

                   8,0,7, 3,0,1, 4,6,0,
                   0,0,0, 0,2,4, 8,0,0,
                   0,0,0, 8,0,0, 9,1,0]
    elsif puzzle=="Random Puzzle"
      puzzles=[]
        File.open("app/models/example_puzzles.txt") do |file|
        while @message=file.gets
          puzzles << @message.chomp.split(//).map { |s| s.to_i }
        end
      end
      array_values = puzzles[rand(puzzles.length)]
    end

    81.times do |i| 
      if (array_values[i]>0)     
        self.big_grid[i]={ value: array_values[i] } 
      else
        self.big_grid[i]={}
      end
    end

  end # fill_in_grid
        
end # class Sudoku
