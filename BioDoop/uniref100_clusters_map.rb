#!/usr/bin/ruby

lineArray = Array.new
uniref_id = String.new
uniref_cluster_id = String.new

STDIN.each_line do |line|

   lineArray = line.split (/\t/)
   uniref_id = lineArray.at(0)
   uniref_cluster_id = lineArray.at(1)
   puts " #{uniref_cluster_id}\t#{uniref_id} "

end
