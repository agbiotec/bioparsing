#!/usr/bin/ruby

accession = String.new
value = String.new
protein = String.new
seq = String.new
taxon = String.new

last_key, accession, value, protein, seq = nil, '', '', '', ''

STDIN.each_line do |line|

    accession, value  = line.split("\t")

    if  last_key && last_key !=accession
        puts "#{seq}\t#{last_key} #{protein} taxon:#{taxon}"
	accession, value, protein, seq = '', '', '', ''

	if value !~ /@@@/
	   (protein,seq) = value.split(/---/)
	   seq.chomp!
	elsif value !~ /---/
	   taxon = value.gsub(/@@@/,"")
	end

    else

        last_key = accession

	if value !~ /@@@/
	   (protein,seq) = value.split(/---/)
	   seq.chomp!
	elsif value !~ /---/
	   taxon = value.gsub(/@@@/,"")
	end

    end

end

puts "#{seq}\t#{accession} #{protein} taxon:#{taxon}"

