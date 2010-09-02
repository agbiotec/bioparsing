#!/usr/bin/ruby

accession = String.new
lineage = String.new
taxon = String.new

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


    if line[0..1].eql? "OX"
	taxon = "TAXON\t" + line.split(/   /).at(1).chop! + "---"
	taxon = taxon.gsub ";", ""
	taxon = taxon.gsub "NCBI_TaxID=", ""
    end


    if line[0..1].eql? "//"
	kingdom = lineage.split(/,/)    
	puts "#{accession}\t#{taxon}#{kingdom[0]}"
	accession = ''    
	lineage = ''
	taxon = ''
    end

end
