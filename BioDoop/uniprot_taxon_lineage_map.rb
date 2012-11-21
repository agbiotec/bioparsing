#!/usr/bin/ruby

accession = String.new
lineage = String.new
kingdom = String.new
#taxon = String.new
lineage_flag = true

STDIN.each_line do |line|

    if line[0..1].eql? "AC"
	accession = line.split(/   /).at(1)
	accession.chop!
	accession.chop!
	accession.gsub "\n", ""
    end	


    if line[0..1].eql? "OC" and lineage_flag
	#lineage = lineage + line.split(/   /).at(1)
	lineage = line.split(/   /).at(1)
	#lineage = lineage.gsub ";", ","
	kingdom = lineage.split(/;/).at(0)
	lineage_flag = false
	#lineage = lineage.gsub " ", ""
	#lineage.chop!
    end


#    if line[0..1].eql? "OX"
#	taxon = "TAXON\t" + line.split(/   /).at(1).chop! + "---"
#	taxon = taxon.gsub ";", ""
#	taxon = taxon.gsub "NCBI_TaxID=", ""
#    end


    if line[0..1].eql? "//"
	puts "#{accession}\tKINGDOM\t#{kingdom}"
	accession = ''    
	lineage = ''
	#taxon = ''
	kingdom = ''
	lineage_flag = true
    end

end
