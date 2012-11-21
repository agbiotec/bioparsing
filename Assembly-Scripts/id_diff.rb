#!/usr/bin/ruby

file1 = File.open(ARGV[0])
file2 = File.open(ARGV[1])
pos = Integer(ARGV[2]) - 1
hash1 = Hash.new
hash2 = Hash.new

file1.each { |line|
     hash1[line.split("\t").at(pos)] = 1
}



file2.each { |line|
     hash2[line.split("\t").at(pos)] = 1
}

array1 = hash1.keys()
array2 = hash2.keys()
set1 = array1 - array2
set2 = array2 - array1
inter = array1 & array2

puts "\n Number of contigs in the first set:  #{array1.size}" 
puts "\n Unique contigs in the first set:  #{set1.size}" 
puts "\n Number contigs in the second set:  #{array2.size}" 
puts "\n Unique contigs in the second set:  #{set2.size}" 
puts "\n Number of contigs at the intersection of the first and second set:  #{inter.size}" 
