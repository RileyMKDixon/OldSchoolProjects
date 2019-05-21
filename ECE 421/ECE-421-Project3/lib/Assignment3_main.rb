require_relative "merge_sort"

testArray = []

1000.times {|i| testArray[i] = Random.rand * 100}
start = Time.now

puts testArray.length
puts "Sorting %d elements..." % [testArray.length]

arr = [ "asasf", "sdsfd", "msafs", "ttyu", "sdg"]
result = Merge_sort.merge_sort_parallel(testArray, 10, reverse=true)

elapsed = Time.now - start

puts result

puts "Sorting Took %0.3f seconds" % [elapsed]