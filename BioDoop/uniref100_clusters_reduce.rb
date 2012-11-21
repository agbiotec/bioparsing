#!/usr/bin/ruby

uniref_id = String.new
uniref_cluster_id = String.new
cluster = String.new
last_key, cluster = nil, '' 

STDIN.each_line do |line|

   uniref_cluster_id, uniref_id  = line.split("\t")
   uniref_id.chop!

   if  last_key && last_key != uniref_cluster_id
       puts "#{last_key}\t#{cluster}"
       last_key, cluster = uniref_cluster_id, uniref_id
   else
       last_key, cluster = uniref_cluster_id,  cluster + ','  + uniref_id                                           
   end 

end


puts "#{last_key}\t#{cluster}" if last_key
