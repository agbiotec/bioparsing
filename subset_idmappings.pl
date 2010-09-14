#!/usr/bin/perl
my (%records_hash_1,%records_hash_2,@record_fields,@uniref_ids,$uniref_id);
open INPUT1, "<$ARGV[0]"; #cross-references for the whole Uniprot (idmappings)
open INPUT3, "<$ARGV[1]"; #the UniRef(100,90,50) for which we get a cross-ref of taxonomy subset
#open INPUT2, "<$ARGV[2]"; #taxonomies for the whole Uniprot
open OUTPUT1, "<$ARGV[2]"; #the cross-reference subset
#open OUTPUT2, "<$ARGV[4]"; #the taxonomy subset

#contains all IDs in Uniprot - concatanates GI, EMBL etc references, in single line for use by Hadoop
while(<INPUT1>)
{
	 chomp;
         @record_fields = split;
	 $records_hash_1{$record_fields[0]} .= "\t$record_fields[1]-$record_fields[2]";

}

#contains taxons for all proteins in Uniprot - for now excluded since we get those from the flat cross-references file 
#while(<INPUT2>)
#{
#	 chomp;
#         @record_fields = split;
#	 $uniref_id = $record_fields[0];
#	 $records_hash_2{$uniref_id} = "$record_fields[1]\t$record_fields[2]";
#
#}

#Contains the subset of ids in Uniref100, Uniref90, Uniref50
while(<INPUT3>)
{
       if ($_=~ />/){
	       @record_fields = split;
	       $uniref_id = $record_fields[0] =~ s/UniRef*_//;
	       push(@uniref_ids,$uniref_id) 
       }

}


foreach (@unirefXids) 
{
	        print OUTPUT1 "$_\t$records_hash_1{$_}\n";
}


close INPUT1;
close INPUT2;
close INPUT3;
close OUTPUT1;
#close OUTPUT2;

