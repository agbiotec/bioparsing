#!/usr/bin/perl
my (%records_hash,@record_fields,$uniref_id,$uniref_map_record);
open INPUT, "<$ARGV[0]";
open OUTPUT, ">$ARGV[1]";
while(<INPUT>)
{
	chomp;
	@record_fields = split;
	$uniref_id = $record_fields[0];
	$records_hash{$uniref_id} .= "\t$record_fields[1]-$record_fields[2]";
}
while ( ($key, $value) = each %records_hash)
{
	print "$key$value\n";
}
close INPUT;
close OUTPUT;
