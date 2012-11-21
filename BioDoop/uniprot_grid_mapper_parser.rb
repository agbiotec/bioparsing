#!/usr/bin/ruby

uniprot = File.open("/usr/local/scratch/kkrampis/uniprot_trembl_sprot.dat")
uniprot_lineage = File.open("/usr/local/scratch/kkrampis/uniprot_id_to_taxon_ruby.dat", "w")

accession = String.new
lineage = String.new

uniprot.each_line do |line|

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
	uniprot_lineage.write "#{accession}\t#{lineage}"
	accession = ''    
	lineage = ''
    end

end
