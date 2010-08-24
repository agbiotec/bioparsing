#!/usr/bin/ruby

accession = String.new
lineage = String.new

STDIN.each_line do |line|

    if line[0..1].eql? "AC"
	accession = line.split(/   /).at(1)
	accession.chop!
	accession.chop!
	accession.gsub "\n", ""
    end	


    if line[0..1].eql? "OC"
	lineage = lineage + line.split(/   /).at(1)
	lineage = lineage.gsub ";", ","
	lineage = lineage.gsub " ", ""
	lineage.chop!
    end


    if line[0..1].eql? "//"
	puts "#{accession}\t#{lineage}"
	accession = ''    
	lineage = ''
    end

end
