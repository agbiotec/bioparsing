#!/usr/bin/ruby

lineArray = Array.new
chrom_pos = String.new
exons = String.new

STDIN.each_line do |line|

    lineArray = line.split(/\s/)
    chrom_pos = lineArray.at(0) + "-" + lineArray.at(1)
    if !lineArray.at(3).nil? 
	    exons = lineArray.at(2) + "-" + lineArray.at(3)
    else
	    exons = lineArray.at(2)
    end

    puts "#{chrom_pos}\t#{exons}"

end
