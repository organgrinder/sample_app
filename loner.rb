line = gets

def loner(line)

  hash = {}

  line.split(//).each do |char|
    puts hashd
    if hash[char]
      hash[char] == 1
      puts "in the if"
    else
      hash[char] == 0
      puts "in the else"
    end
  end
  
  hash.each do |key, value|
    return key if value == 1
  end
  
end

puts loner(line)