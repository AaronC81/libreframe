class Array
  # Acts like #each_cons, but starts with an element which wraps between the
  # final element and the first one.
  # Example: [1, 2, 3].each_cons_wrap(2) #=> [[3, 1], [1, 2], [2, 3]]
  def each_cons_wrap(count)
    [[self[-1]] + self[0...count - 1]] + each_cons(count).to_a
  end
end