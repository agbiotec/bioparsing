#!/usr/bin/perl

use strict;

my (%records_hash,@record_fields);
open INPUT1, "<$ARGV[0]"; ##the file with the default uniref100 cross reference (idmapping.tab) 
open INPUT2, "<$ARGV[1]"; #the file with additional cross-refs parsed by Hadoop

#reads from STDIN as it is streamed by Hadoop
while(<>)
{
	  @record_fields = split;
	  $records_hash{$record_fields[0]} = 1; 

}


while(<INPUT1>)
{
         @record_fields = split;
	 if ($records_hash{$record_fields[0]}) {
		 print $_;
	 }
}


while(<INPUT2>)
{
         @record_fields = split;
	 if ($records_hash{$record_fields[0]}) {
		 print $_;
	 }
}


close INPUT1;
close INPUT2;
