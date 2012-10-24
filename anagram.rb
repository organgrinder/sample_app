word1 = gets
word2 = gets

def anagram(word1, word2)
  array1 = word1.chomp.split(//)
  array2 = word2.chomp.split(//)
  letters = {}
  
  array1.each do |letter|
    if letter == " "
      next
    elsif letters[letter]
      letters[letter] += 1
    else
      letters[letter] = 1
    end
    puts letters
  end
  
  array2.each do |letter|
    if letter == " "
      next
    elsif !letters[letter]
      return "they are not anas, not even close"
    else
      letters[letter] -= 1
    end
    puts letters
  end
  
  letters.each do |letter, count|
    if count != 0
      return "they are not anas"
    end
  end
  
  return "they are anas"
end

puts anagram(word1, word2)