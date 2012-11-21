#!/usr/bin/ruby

#the posmap.frgctg file
file1 = File.open(ARGV[0])
#the posmap.mates file
file2 = File.open(ARGV[1])
#the output file
file3 = File.open(ARGV[2], 'w')
#a hash to hold fragment (read) to contig mapping info from posmap.frgctg
hash1 = Hash.new

#fill hash1
file1.each { |line|
     line_elements = line.split("\t")
     hash1[line_elements.at(0)] = line_elements.at(1)
}


#read the posmap.mates file and write a updated one which additionally contains the contig info
file2.each { |line|
     line_elements = line.split("\t")
     #print readID1 Contig1 readID2 Contig2 MateStatus
     file3.puts("#{line_elements.at(0)}\t#{hash1[line_elements.at(0)]}\t#{line_elements.at(1)}\t#{hash1[line_elements.at(1)]}\t#{line_elements.at(2)}")

}

