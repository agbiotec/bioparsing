#!/usr/bin/perl
my (%records_hash,@record_fields,$uniref100_id,$uniref_map_record);
open INPUT1, "<$ARGV[0]"; #uniref100
open INPUT2, "<$ARGV[1]"; #mappings
open OUTPUT, ">$ARGV[2]"; #the uniref100 ids that are missing from the mappings file

while(<INPUT1>)
{
	chomp;
        if ($_=~ />/){

	       @record_fields = split;
	       $record_fields[0] =~ s/>UniRef[0-9]+_//;
	       $records_hash{$record_fields[0]} = 1; 
	}
}

while (<INPUT2>)
{

	 chomp;
	 $_ =~ s/;//g;
         @record_fields = split(/\t/,$_);
	 delete $records_hash{$record_fields[8]};
}


foreach ( keys %records_hash ) {
	print OUTPUT "$_\n";
}

close INPUT1;
close INPUT2;
close OUTPUT;
