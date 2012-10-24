line = gets
letter = gets

def remover(line, letter)
  array = line.chomp.split(//)
  remove_me = letter.chomp
  array.delete(remove_me)
  array.join()
end

puts remover(line, letter)