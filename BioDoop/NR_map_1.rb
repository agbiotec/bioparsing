#!/usr/bin/ruby

members = Array.new
seq = String.new
acc_head = String.new
acc_taxon = String.new
taxon = String.new

STDIN.each_line do |line|

   line.chomp!

   if line[0..0].eql? ">"
	members = line.split(/>/)

   elsif line[0..12].eql? "NCBI sequence"
        acc_taxon = line.split(/:/).at(1).strip.gsub(/\|$/,"")
     
   elsif line[0..12].eql? "NCBI taxonomy"
        taxon = line.split(/:/).at(1).strip

   elsif !line.eql? "" and !line[0..5].eql? "Common" and !line[0..9].eql? "Scientific"
	seq = line
	seq.strip
   end




   if !members.empty? and !seq.eql? ""

       members.each { |acc_head|
          acc_head_split = acc_head.split(/\| /)
	  if !acc_head_split.at(1).eql? nil
             puts "#{acc_head_split.at(0).strip}\t#{acc_head_split.at(1).strip.gsub(/ \[.*\]/,"")}---#{seq}"
          end
       }

       members.clear
       seq = ''
   end


   if !acc_taxon.eql? "" and !taxon.eql? ""

       puts "#{acc_taxon}\t@@@#{taxon}"
       acc_taxon = ''
       taxon = ''
   end 

end
