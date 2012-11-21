#!/usr/bin/ruby

accession = String.new
reviewed = ''
taxon = String.new
dr = String.new
ec_1 = Array.new
ec_2 = Array.new
go = Array.new
gn = String.new
cazys = Array.new
gn_pre = String.new
de = String.new
#kingdom = String.new
#lineage = String.new
#lineage_flag = true

STDIN.each_line do |line|

    if line[0..1].eql? "AC"
	accession = line.split(/   /).at(1)
	if !accession.nil?
           accession = accession.split(/;/).at(0)
	end
    end	


    if line[0..1].eql? "ID" and line !~ /Unreviewed/
	reviewed = 'TRUE'
    elsif line[0..1].eql? "ID" and line !~ /Reviewed/
	reviewed = 'FALSE'
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
	dr = line.split(/   /).at(1)

	if dr =~ /BRENDA/ 
	    dr.chop!
	    ec_1_pre = String.new
	    ec_1_pre = dr.split(/;/).at(1)
	    ec_1_pre = ec_1_pre.gsub "\s", ""
	    ec_1.push(ec_1_pre)
	end    
       
	if dr =~ /GO;/ 
	    dr.chop!
	    dr = dr.gsub "GO; ", ""
	    dr = dr.gsub /;.*$/, ""
            go.push(dr) 
	end
 
	if dr =~ /CAZy/ 
	    dr.chop!
            cazys.push(dr.split(/; /).at(1))
	end

    end


    if line[0..1].eql? "GN"

	gn_pre = line.split(/   /).at(1)

        if  gn_pre !~ /Synonym/ and !gn_pre.nil?
	       gn_pre.chop!
	       gn = gn_pre.split(/;/).at(0)
	       #gn = gn.gsub "Name=",""
	       #gn = gn.gsub "OrderedLocusNames=",""
	       #gn = gn.gsub "ORFNames=",""
	       name_pos = gn =~ /^Name=/
	       if name_pos == 0 
	          #gn = gn.gsub /.*[Nn]ame.*=/,''
	          gn = gn.gsub /Name=/,''
	       else gn = ''
	       end
	       name_pos = 1
	end
    end


    if line[0..1].eql? "DE" and de.eql? '' 

	if (line.include? "Full" and !line.include? "Flags")
	   de = line.split(/   /).at(1).chop! 
	   de = de.gsub ";",""
	   #de = de.gsub /.+ Full=/,''
	   de = de.gsub /.*[Nn]ame.*=/,''
	   #de = de.gsub "SubName: Full=",""
	   #de = de.gsub "RecName: Full=",""
	   #de = de.gsub "AltName: Full=",""
	end
    end

    if line[0..1].eql? "DE" 
	    	
	if (line.include? "EC=")
	   ec_2_pre = String.new
	   #ec_2_pre = line.gsub /DE\s+/, ''
	   ec_2_pre = line.split(/            /).at(1).chop! 
	   ec_2_pre = ec_2_pre.gsub ";",""
	   ec_2_pre = ec_2_pre.gsub "EC=", ""
	   ec_2.push(ec_2_pre)
	end

    end


    if line[0..1].eql? "//"

	if !taxon.eql? "" 
		puts "#{accession}\tTAXON\t#{taxon}"
	end

	if !reviewed.eql? "" 
		puts "#{accession}\tREVIEWED\t#{reviewed}"
	end

        ec_1.each { |ec_1_|
		puts "#{accession}\tEC_DR\t#{ec_1_}"
	}

        ec_2.each { |ec_2_|
		puts "#{accession}\tEC_DE\t#{ec_2_}"
	}

        go.each { |go_id|
		puts "#{accession}\tGO\t#{go_id}"
	}

	if !gn.eql? ""
		puts "#{accession}\tGN\t#{gn}"
        end	

	cazys.each { |cazy|
		puts "#{accession}\tCAZY\t#{cazy}"
        }	

	if de.size > 0 
		puts "#{accession}\tDE\t#{de}"
        end	

	accession = ''    
	taxon = ''
	dr = ''
        reviewed = ''
	ec_1.clear
	ec_2.clear
	go.clear
	gn = ''
	de = ''
	cazys.clear
    end

end
