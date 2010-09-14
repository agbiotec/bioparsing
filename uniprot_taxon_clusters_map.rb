#!/usr/bin/ruby

lineArray = Array.new
accession = String.new
uniref100 = String.new
taxon = String.new

STDIN.each_line do |line|

    lineArray = line.split(/\t/)
    accession = lineArray.at(0)
    uniref100 = lineArray.at(8)
    taxon = lineArray.at(13)
    puts "#{uniref100}\t#{accession}\t#{taxon}"

end
