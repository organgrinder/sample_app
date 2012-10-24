class Node
  
  def value
    @value
  end
  
  def value=(value)
    @value = value
  end
  
  def right=(node)
    @right = node
  end
  
  def left=(node)
    @left = node
  end
  
  def right
    @right
  end
  
  def left
    @left
  end
  
  def height
    return 0 if !(right) && !(left)
    return [right.height, left.height].max + 1 if right && left
    return right.height + 1 if right
    return left.height + 1 if left
  end
  
  def print
    
  end
  
end

def insert_value(node, value)
  if !node.value
    node.value = value
  elsif value < node.value
    node.left = Node.new if !node.left
    insert_value(node.left, value)
  else 
    node.right = Node.new if !node.right
    insert_value(node.right, value)
  end
end

def set_value(node, value)
  node.value=value
end

def queue_in_order(node, array)
  array << node.value
  if node.left
    queue_in_order(node.left, array)
  else
    array << " "
  end
  if node.right
    queue_in_order(node.right, array)
  else
    array << " "
  end
end

def inspect_in_order(node)
  puts node.value
  inspect_in_order(node.left) if node.left
  inspect_in_order(node.right) if node.right
end

def inspect_pre_order(node)
  inspect_pre_order(node.left) if node.left
  puts node.value
  inspect_pre_order(node.right) if node.right
end

def pow2(number)
  return number & number - 1 == 0
end

def drawer(tree)
  printer = []
  queue = [tree]
  while (queue_is_live(queue) || !pow2(printer.size + 1))
    current = queue.shift
    if current.left
      queue << current.left 
    else
      dummy = Node.new
      dummy.value = "o"
      queue << dummy
    end
    
    if current.right
      queue << current.right
    else
      dummy = Node.new
      dummy.value = "o"
      queue << dummy
    end
    printer << current.value
  end
  return printer
end

def queue_is_live(array)
  array.each do |item|
    return true if item.value != "o"
  end
  return false
end

def tree_printer(array)
  d = Math.log2(array.size + 1).to_i - 1
  row = 0
  array.size.times do |i|
    if (i+1) & i == 0
      print "\n"
      row = Math.log2(i+1).to_i
      ((2**(d-row))-1).times { print " " }
    else
      ((2**(d-row+1))-1).times { print " " }
    end
    print array[i]
  end
  print "\n\n"
end

def balance_tree(tree)
  if  tree.left &&
      tree.right &&
      tree.left.height > tree.right.height + 1
    middle = tree.left.right
    tree.left.right = tree
    tree = tree.left
    tree.right.left = middle
    return tree
  elsif tree.left &&
        tree.right &&
        tree.right.height > tree.left.height + 1
    middle = tree.right.left
    tree.left.right = tree
    tree = tree.right
    tree.left.right = middle
    return tree
  else
    return tree
  end
end

array1 = []
while line = gets
  break if line == "n\n" 
  array1 << line.chomp.to_i
end

tree = Node.new

array1.each do |item|
  insert_value(tree, item)
end

tree_printer(drawer(tree))
tree = balance_tree(tree)
tree_printer(drawer(tree))

