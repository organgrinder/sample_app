class Sudoku < ActiveRecord::Base

  attr_accessible :content, :big_grid
  serialize :big_grid
  
  def apply_rules
    return rule_4 || rule_1 || rule_2 || rule_3
  end # apply_rules

  def rule_1
    
    # return value is hash with :rule => String and :locations => Array
    # used to build up lists of rules used and locations solved
    
    9.times do |number_index|
      number = number_index + 1

      9.times do |current_cube_number|
        if (all_possible_spots_in_cube(number, current_cube_number) == 1)

          winner_location = first_possible_spot_in_cube(number, current_cube_number)
          big_grid[winner_location][:value] = number
          big_grid[winner_location][:possibilities] = []

          erase_possibilities(number, current_cube_number)
          
          return { 
            rule_text: "Rule 1:  Pick a 3x3 cube and pick a number.  If there 
          is only 1 spot in that cube where that number can go (based on other numbers 
          filled in, but not possibilities recorded), fill it in.", 
            locations: [winner_location]
          }
        end # if
      end # 9.times do

    end # 9.times do
    
    return false
  end # rule_1

  def rule_2

    9.times do |number_index|
      number = number_index + 1

      9.times do |current_cube_number|
        if (all_possible_spots_in_cube(number, current_cube_number) == 2)
          
          winner_location1 = first_possible_spot_in_cube(number,current_cube_number)
          winner_location2 = second_possible_spot_in_cube(number,current_cube_number)

          unless big_grid[winner_location1][:possibilities].include?(number)
            big_grid[winner_location1][:possibilities] << number
            big_grid[winner_location2][:possibilities] << number
            return { 
              rule_text: "Rule 2:  Pick a number and pick a cube.  If there are exactly 2 spots in the cube 
              where that number can go, record them as possibilities (indicated by small text).",
              locations: [winner_location1, winner_location2]
            }
          end # unless
                    
        end # if 
      end # 9.times do |current_cube_number
      
    end # 9.times do |number_index|
                    
    return false 
  end # rule_2

  def rule_3
    
    9.times do |number_index|
      number = number_index + 1

      9.times do |current_cube_number|
        if (all_possible_spots_in_cube_complex(number, current_cube_number) == 1)
          
          winner_location = first_possible_spot_in_cube_complex(number, current_cube_number)
          big_grid[winner_location][:value] = number
          big_grid[winner_location][:possibilities] = []

          erase_possibilities(number, current_cube_number)

          return { 
            rule_text: "Rule 3:  Pick a number and pick a cube.  If there is only spot in the cube 
            where that number can go (considering numbers filled in AND possibilities recorded), 
            fill in that spot.  Erase all possibilities in that spot.  Erase anywhere else 
            in that cube that number was listed as a possibility.",
            locations: [winner_location]
          }
            
        end # if
      end # 9.times do
    end # 9.times do
            
    return false
    
  end # rule_3

  def rule_4
    9.times do |number_index|
      number = number_index + 1
  
      9.times do |current_cube_number|
        items = cube_objects_by_number(current_cube_number)
        times_found = 0
        winner_location = 81
        
        items.each do |item|
          if item[:possibilities].include?(number)
            times_found += 1
            winner_location = item[:location]
          end # if
        end # do
      
        if times_found == 1
          big_grid[winner_location][:value] = number
          big_grid[winner_location][:possibilities] = []
          return { 
            rule_text: "Rule 4:  Pick a number and pick a cube.  If that number appears 
            as a possibility in just 1 spot in that cube, fill in that spot with that 
            number.  Erase all possibilities in that spot.",
            locations: [winner_location]
          }
        end # if
      end # 9.times do
    end # 9.times do
  
    return false
  end # rule_4
  
  def solved
    return false if !self.big_grid
    self.big_grid.each do |item|
      return false if !item[:value]
    end
    return true
  end
  
  def erase_possibilities(number, cube_number)
    locations = cube_locations_by_number(cube_number)
  
    locations.each do |location|
      big_grid[location][:possibilities].length.times do |i|
        if big_grid[location][:possibilities][i] == number
          big_grid[location][:possibilities][i] = nil
        end
      end
    end
  end

  def first_possible_spot_in_cube(number, cube_number)
    locations_in_cube = cube_locations_by_number(cube_number)
    locations_in_cube.each do |location|
      return location if (can_go_in_spot(number,location))
    end

    return 81 # error tracking; should never get to this line
  end

  def first_possible_spot_in_cube_complex(number, cube_number)
    locations_in_cube = cube_locations_by_number(cube_number)
    locations_in_cube.each do |location|
      return location if (can_go_in_spot_complex(number,location))
    end

    return 81 # error tracking; should never get to this line
  end


  def second_possible_spot_in_cube(number, cube_number)
    locations_in_cube = cube_locations_by_number(cube_number)
    
    locations_in_cube.each do |location|
      return location if  can_go_in_spot(number,location) && 
                          !(first_possible_spot_in_cube(number, cube_number)==location)
    end

    return 81 # error tracking; should never get to this line
  end
  
  def all_possible_spots_in_cube(number, cube_number)
    spots = 0
    locations_in_cube = cube_locations_by_number(cube_number)

    locations_in_cube.each do |location|
      spots += 1 if (can_go_in_spot(number, location))
    end

    return spots
  end
  
  def all_possible_spots_in_cube_complex(number, cube_number)
    spots = 0
    locations_in_cube = cube_locations_by_number(cube_number)
    
    locations_in_cube.each do |location|
      spots += 1 if (can_go_in_spot_complex(number, location))
    end
    
    return spots
  end

  def can_go_in_spot(number, location)
    return !( column_values_by_location(location).include?(number) || 
              row_values_by_location(location).include?(number) ||
              cube_values_by_location(location).include?(number) ||
              big_grid[location][:value])
  end
  
  def can_go_in_spot_complex(number, location)
    return (can_go_in_spot(number, location) && 
            can_go_in_row_complex(number, location) && 
            can_go_in_column_complex(number, location))
  end
  
  def can_go_in_row_complex(number, location)
    row_items = row_items_by_location(location)
    items_matching_possibility = []
    
    row_items.each do |item|
      if item[:possibilities].include?(number)
        items_matching_possibility.each do |possible|
          if (cube_number_by_location(possible[:location]) == cube_number_by_location(item[:location]) &&
              cube_number_by_location(possible[:location]) != cube_number_by_location(location))
            return false
          end
        end
        items_matching_possibility << item
      end
    end
    
    return true
  end

  def can_go_in_column_complex(number, location)
    col_items = column_items_by_location(location)
    items_matching_possibility = []
    
    col_items.each do |item|
      if item[:possibilities].include?(number)
        items_matching_possibility.each do |possible|
          if (cube_number_by_location(possible[:location]) == cube_number_by_location(item[:location]) &&
              cube_number_by_location(possible[:location]) != cube_number_by_location(location))
            return false
          end
        end
        items_matching_possibility << item
      end
    end
    
    return true
  end

  def cube_locations_by_number(number)
    start_location = cube_start_location_by_number(number)
    cube_locations = Array.new(9)
    
    9.times do |i|
      cube_locations[i] = start_location
      if (i%3 == 2) 
        start_location += 7
      else
        start_location += 1
      end
    end
    
    return cube_locations
  end

  def cube_number_by_location(location)
      return 0 if (location % 9 < 3 && location < 27)
      return 1 if (location % 9 > 2 && location % 9 < 6 && location < 27)
      return 2 if (location % 9 > 5 && location < 27)
      return 3 if (location % 9 < 3 && location > 26 && location < 54)
      return 4 if (location % 9 > 2 && location % 9 < 6 && location > 26 && location < 54)
      return 5 if (location % 9 > 5 && location > 26 && location < 54)
      return 6 if (location % 9 < 3 && location > 53)
      return 7 if (location % 9 > 2 && location % 9 < 6 && location > 53)
      return 8 if (location % 9 > 5 && location > 53)
    end

  def cube_values_by_location(location)
    return cube_values_by_number(0) if (location % 9 < 3 && location < 27)
    return cube_values_by_number(1) if (location % 9 > 2 && location % 9 < 6 && location < 27)
    return cube_values_by_number(2) if (location % 9 > 5 && location < 27)
    return cube_values_by_number(3) if (location % 9 < 3 && location > 26 && location < 54)
    return cube_values_by_number(4) if (location % 9 > 2 && location % 9 < 6 && location > 26 && location < 54)
    return cube_values_by_number(5) if (location % 9 > 5 && location > 26 && location < 54)
    return cube_values_by_number(6) if (location % 9 < 3 && location > 53)
    return cube_values_by_number(7) if (location % 9 > 2 && location % 9 < 6 && location > 53)
    return cube_values_by_number(8) if (location % 9 > 5 && location > 53)
  end

  def cube_values_by_number(number)
    start_location = cube_start_location_by_number(number)
    cube = Array.new(9)

    9.times do |i|
      cube[i] = big_grid[start_location][:value]
      if (i % 3 == 2) 
        start_location += 7
      else
        start_location += 1
      end
    end

    return cube
  end
  
  def cube_objects_by_number(number)
    start_location = cube_start_location_by_number(number)
    cube = Array.new(9)

    9.times do |i|
      cube[i] = big_grid[start_location]
      if (i % 3 == 2) 
        start_location += 7
      else
        start_location += 1
      end
    end

    return cube
  end
  
  def cube_start_location_by_number(number)
    return 0 if (number == 0)
    return 3 if (number == 1)
    return 6 if (number == 2)
    return 27 if (number == 3)
    return 30 if (number == 4)
    return 33 if (number == 5)
    return 54 if (number == 6)
    return 57 if (number == 7)
    return 60 if (number == 8)
  end
  
  def row_values_by_number(number)
    return row_values_by_location(number * 9)
  end
  
  def column_values_by_number(number)
    return column_values_by_location(number)
  end

  def row_values_by_location(location)
    start_location = location-location % 9
    row=Array.new(9)

    9.times do |i|
      row[i] = big_grid[start_location][:value]
      start_location += 1
    end

    return row
  end

  def column_values_by_location(location)
    start_location = location % 9
    column = Array.new(9)

    9.times do |i|
      column[i] = big_grid[start_location][:value]
      start_location += 9
    end

    return column
  end
  
  def row_items_by_location(location)
    start_location = location-location % 9
    row=Array.new(9)

    9.times do |i|
      row[i] = big_grid[start_location]
      start_location += 1
    end

    return row
  end

  def column_items_by_location(location)
    start_location = location % 9
    column = Array.new(9)

    9.times do |i|
      column[i] = big_grid[start_location]
      start_location += 9
    end

    return column
  end
  
  def self.createDefault(params)
    # Class Method
    # create the default puzzle
    
    grid = [0,8,9,0,1,0,0,0,0,6,7,0,4,0,0,0,0,
            5,0,0,0,0,0,0,1,3,0,0,4,3,6,0,0,0,
            1,0,5,6,0,0,0,0,0,7,2,0,1,0,0,0,5,
            3,6,0,0,9,7,0,0,0,0,0,0,2,0,0,0,0,
            9,0,8,7,0,0,0,0,3,0,2,9,0]
            
    self.create(params.merge(:big_grid => massage_grid(grid)))
  end
  
  def self.createRandom(params)
    # Class Method
    # create a random puzzle

    @puzzles ||= []
    @puzzle_file ||= open("app/models/example_puzzles.txt") do |f|
      f.each_line do |line|
        @puzzles << line.split(//).map(&:to_i)
      end
    end
    
    grid = @puzzles[rand(@puzzles.length)]
    
    self.create(params.merge(:big_grid => massage_grid(grid)))
  end
  
  def self.massage_grid(grid)
    massaged = []
    
    81.times do |i| 
      if (grid[i] > 0)     
        massaged[i] = { value: grid[i] } 
      else
        massaged[i] = {}
      end
      massaged[i][:location] = i
      massaged[i][:possibilities] = []
      # am hoping this doesn't break anything b/c we never test for big_grid[i]=nil
    end
    
    massaged
  end
end # class Sudoku
