#!/usr/bin/ruby

#contains the contains in the first set (assembly vs reference 1)
file1 = File.open(ARGV[0])
#contains the contains in the first set (assembly vs reference 1)
file2 = File.open(ARGV[1])
#containts readID1 Contig1 readID2 Contig2 MateStatus (made by matesToContigs.rb)
file3 = File.open(ARGV[2])
#column in the assembly vs reference results where the contig ids are
pos = Integer(ARGV[3]) - 1
hash1 = Hash.new
hash2 = Hash.new
i = 0
j = 0

#a hash holding the contigs of the first set
file1.each { |line|
     hash1[line.split("\t").at(pos)] = 1
}


#a hash holding the contigs of the first set
file2.each { |line|
     hash2[line.split("\t").at(pos)] = 1
}


#read the file with the readID1 Contig1 readID2 Contig2 MateStatus (made by matesToContigs.rb)
file3.each { |line|
     line_elements = line.split("\t")
     #contigs are in different assembly vs reference hit sets
     if ( (hash1[line_elements.at(1)] and hash2[line_elements.at(3)]) or (hash2[line_elements.at(1)] and hash1[line_elements.at(3)]) )
        if (line_element.at(4) == "good") 
	  i = i+1
	else 
	  j = j+1
        end

     end
     

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
puts "\n Reads with mates in THE SAME + PROPER DISTANCE ('good' in posmap) contigs of the first and second set:  #{i} "
puts "\n Reads with mates in DIFFENT OR IMPROPER DISTANCE (not 'good') contigs of the first and second set:  #{j} "
