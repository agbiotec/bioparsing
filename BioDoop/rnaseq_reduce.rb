#!/usr/bin/ruby

exon_start, exon_end, gene_id, count = nil, nil, nil, 0

STDIN.each_line do |line|

   pos, read_count  = line.split("\t")
   read_count.chop!

   if  read_count =~ /_/ 
       exon_end, gene_id = read_count.split("-")
       rand1, rand2, exon_start = pos.split("-")
       if count
          puts "#{gene_id}\t#{count}"
          count = 0
       end
   else
       rand1, rand2, read_map = pos.split("-")
       if exon_start.to_i < read_map.to_i && read_map.to_i < exon_end.to_i
          count = count + read_count.to_i
       end
   end 
end


puts "#{gene_id}\t#{count}"
