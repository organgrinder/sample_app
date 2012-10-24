array1 = []
array2 = []

while line = gets
  break if line == "n\n" 
  array1 << line.chomp.to_i
end

# while line = gets
#   break if line == "n\n" 
#   array2 << line.chomp.to_i
# end

def missing(array)
  array2 = []
  array.each do |item|
    array2[item] = 1
  end
  array.length.times do |i|
    return i+1 if array2[i+1] != 1
  end
  return "error"
end

def dup(array)
  hashy = {}
  array.each do |item|
    return item if hashy[item] == 1
    hashy[item] = 1
  end
  return "error"
end

def dupes(array)
  hasy = {}
  array.each do |item|
    hasy[item] = (hasy[item] || 0) + 1
  end
  
  dupes_array = []
  hasy.each do |key, value|
    dupes_array << key if value == 2
  end
  
  return dupes_array.to_s
end
  
def missing_num(array1, array2)
  hasy = {}
  array2.each do |item|
    hasy[item] = ""
  end

  array1.each do |item|
    return item.to_s + " is missing" if !(hasy[item])
  end
  
  return "none missin"
end

def second_highest(array)

  first, second = array.first, array.first
  
  array.each do |item|
    if item > first
      second = first
      first = item
    elsif item > second
      second = item
    end
  end
  return second
end  

puts second_highest(array1)


