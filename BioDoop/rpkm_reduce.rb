#!/usr/bin/ruby

last_key, cluster_members, taxon_ids = nil, '', '' 

STDIN.each_line do |line|

    uniref100, accession, taxon  = line.split("\t")
    taxon.chop!

    if  last_key && last_key != uniref100
        puts "#{last_key}\tCLUSTERS\t#{cluster_members}\t#{taxon_ids}"
        last_key, cluster_members, taxon_ids = uniref100, accession, taxon 
    else
        last_key, cluster_members, taxon_ids  = uniref100, cluster_members + ',' + accession , taxon_ids + ',' + taxon
    end

end

puts "#{last_key}\tCLUSTERS\t#{cluster_members}\t#{taxon_ids}" if last_key

