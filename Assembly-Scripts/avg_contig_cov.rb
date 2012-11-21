#!/usr/bin/ruby
#posmap.frgutg
file1 = File.open(ARGV[0])
#posmap.utglength
file2 = File.open(ARGV[1])
#keeps read sizes in each contig
hash1 = Hash.new
#keeps the contig size
hash2 = Hash.new

file1.each { |line|
     line_array = line.split("\t")

     if hash1[line_array[1]].nil? then
        hash1[line_array[1]] = []
        hash1[line_array[1]].push((Integer(line_array[2]) - Integer(line_array[3])).abs)
     else
        hash1[line_array[1]].push((Integer(line_array[2]) - Integer(line_array[3])).abs)
        #hash1[line_array[1]].push(abs(line_array[2] - line_array[3]))
     end
}


#we need total_read_length / contig_length
#here we calculate total_read_length
hash1.keys.each { |key|

     total_read_size = 0
     hash1[key].each { |read_size|
          total_read_size = total_read_size + read_size
     }

     hash1[key] = total_read_size
}


#here parse out the contig_length
file2.each { |line|
     hash2[line.split("\t").at(0)] = line.split("\t").at(1).chomp
}

#sort based on contig size
hash2.sort_by { |k,v| v }

puts "contig ID\tcontig length\tavg contig coverage"
hash2.keys.each { |key|
	puts "#{key}\t#{hash2[key]}\t#{Integer(hash1[key])/Integer(hash2[key])}"
}

