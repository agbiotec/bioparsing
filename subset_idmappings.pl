#!/usr/bin/perl

use strict;

my (%records_hash,@record_fields,@uniref_ids,@lineage, $accession,$kingdom);
open INPUT1, "<$ARGV[0]"; #the UniRef(100,90,50) for which we get a cross-ref or taxonomy subset
open INPUT2, "<$ARGV[1]"; #cross-references for the whole Uniprot (idmappings)
open INPUT3, "<$ARGV[2]"; #the Trembl-sprot files with lineages
open OUTPUT1, ">$ARGV[3]"; #the cross-reference subset
open OUTPUT2, ">$ARGV[4]"; #the Uniref subset for cluster members
open OUTPUT3, ">$ARGV[5]"; #the lineage subset


#Contains the subset of ids in Uniref100, Uniref90, Uniref50
while(<INPUT1>)
{
       if ($_=~ />/){
	       @record_fields = split;
	       $record_fields[0] =~ s/>UniRef[0-9]+_//;
	       $records_hash{$record_fields[0]} = 1; 
       }

}


#contains all IDs in Uniprot - concatanates GI, EMBL etc references, in single line for use by Hadoop
while(<INPUT2>)
{
	 chomp;
	 $_ =~ s/;//g;
         @record_fields = split(/\t/,$_);
	 if ( $records_hash{$record_fields[0]} ) {
	   
	    print OUTPUT1 "$record_fields[0]\tUniProtKB-ID-$record_fields[1]\tGeneID-$record_fields[2]\tRefSeq-$record_fields[3]\tGI-$record_fields[4]\tPDB-$record_fields[5]\tGO-$record_fields[6]\tIPI-$record_fields[7]\tPIR-$record_fields[12]\tTaxon-$record_fields[13]\tMIM-$record_fields[14]\tUniGene-$record_fields[15]\tEMBL-$record_fields[17]\tEnsembl-$record_fields[19]\n";

	    print OUTPUT2 "$record_fields[0]\t$record_fields[8]\t$record_fields[13]\n";
	 }


}

#contains all lineages in UniProt / Trembl

while(<INPUT3>){

        chomp; 
        @record_fields = split;

	if ($record_fields[0] eq 'AC' ) {
            $accession = $record_fields[1];
	    $accession =~ s/;//;

        }

	if ($record_fields[0] eq 'OC') {
	 
	    @lineage = split(/;/, $record_fields[1]);
	    $kingdom = $lineage[0]; 
	}


        if ($_ =~ /\/\//) {

	    print OUTPUT3 "$accession\tKINGDOM\t$kingdom\n" if $records_hash{$accession} 
	}
}




close INPUT1;
close INPUT2;
close INPUT3;
close OUTPUT1;
close OUTPUT2;

