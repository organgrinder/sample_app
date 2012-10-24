line = gets

def pallindrome(line)
  array = line.chomp.split(//)
  array2 = []
  array.length.times do |index|
    array2[index] = array[array.length - index - 1]
  end
  return true if array == array2
  return false

end

def pallindrome_one_array(line)
  array = line.chomp.split(//)
  (array.length / 2).times do |index|
    puts array[index]
    puts array[array.length - index - 1]
    return false if array[index] != array[array.length - index - 1]
  end
  return true
end

puts pallindrome_one_array(line)