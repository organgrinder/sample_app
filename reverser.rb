line = gets

def reverser(line)
  array = line.split(" ")
  newline = ""
  array.length.times do
    newline << array.pop
    newline << " "
  end
  return newline
end

puts reverser(line)