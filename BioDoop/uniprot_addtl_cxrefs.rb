#!/usr/bin/ruby

accession = String.new
reviewed = FALSE
taxon = String.new
dr = String.new
ec = String.new
go = String.new
gn = String.new
de = String.new
de_pre = String.new
#kingdom = String.new
#lineage = String.new
#lineage_flag = true

STDIN.each_line do |line|

    if line[0..1].eql? "AC"
	accession = line.split(/   /).at(1)
        accession = accession.split(/;/).at(0)
    end	


    if line[0..1].eql? "ID" and line.grep(/Reviewed/)
	reviewed = TRUE
    end	


#    if line[0..1].eql? "OC" #and lineage_flag
#	lineage = lineage + line.split(/   /).at(1)
#	#lineage = line.split(/   /).at(1)
#	lineage = lineage.gsub ";", ","
#	#kingdom = lineage.split(/;/).at(0)
#	#lineage_flag = false
#	lineage = lineage.gsub " ", ""
#	lineage.chop!
#    end


#    if line[0..1].eql? "OX"
#	taxon = "TAXON\t" + line.split(/   /).at(1).chop! + "---"
#	taxon = taxon.gsub ";", ""
#	taxon = taxon.gsub "NCBI_TaxID=", ""
#    end




    if line[0..1].eql? "OX"
	taxon = line.split(/   /).at(1).chop! 
	taxon = taxon.gsub ";", ""
	taxon = taxon.gsub "NCBI_TaxID=", ""
    end



    if line[0..1].eql? "DR"
	dr = line.split(/   /).at(1).chop!

	if dr =~ /BRENDA/
	    ec = dr.split(/;/).at(1)
	    ec = ec.gsub "\s", ""
	end    
       
	if dr =~ /GO;/
            go = go + dr + " // "
	end
 
    end


    if line[0..1].eql? "GN"
	gn = line.split(/   /).at(1).chop! 
    end


    if line[0..1].eql? "DE"
	de_pre = line.split(/   /).at(1).chop! 
	if !de_pre.nil? 
           de = de + de_pre + " // "
	end    	
    end


    if line[0..1].eql? "//"
	#puts "#{accession}\tKINGDOM\t#{kingdom}"
	puts "#{accession}\tTAXON\t#{taxon}"
	puts "#{accession}\tREVIEWED\t#{reviewed}"
	puts "#{accession}\tEC\t#{ec}"
	puts "#{accession}\tGO\t#{go}"
	puts "#{accession}\tGN\t#{gn}"
	puts "#{accession}\tDE\t#{de}"
	accession = ''    
	taxon = ''
	dr = ''
	ec = ''
	go = ''
	gn = ''
	de = ''
	de_pre = ''
	#lineage = ''
	#kingdom = ''
	#lineage_flag = true
    end

end
