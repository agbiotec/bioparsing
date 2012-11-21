#!/usr/bin/perl

use strict;

my (%gb_hash, %rf_hash, @record_fields, $gb, $rf, $gb_gi, $rf_gi);
open INPUT1, "<$ARGV[0]"; # GB to GI mapping file
open INPUT2, "<$ARGV[1]"; # RF to GI mapping file
open INPUT3, "<$ARGV[2]"; # Uniref100 PANDA
open OUTPUT1, ">$ARGV[3]"; # updated Uniref100 PANDA

$gb = '';
$rf = '';

while(<INPUT1>)
{
	       @record_fields = split(/,/);
	       chomp($record_fields[2]); 
	       $gb_hash{$record_fields[0]} = $record_fields[2]; 
}


while(<INPUT2>)
{
	       @record_fields = split(/\t/);
	       $rf_hash{$record_fields[2]} = $record_fields[3]; 
}



while(<INPUT3>)
{

	 if ($_ =~ /^>/) {
		
                 $_ =~ /\^\|\^RF\|(.+\.[0-9])\^\|\^/;
		 $rf = $1;
		 $_ =~ /\^\|\^GB\|(.+[0-9])\|/;
		 $gb = $1;
		 $_ =~ s/\^\|\^RF\|(.+\.[0-9])\^\|\^/\^\|\^RF\|$rf\|$rf_hash{$rf}\^\|\^/;
		 $_ =~ s/\^\|\^GB\|.+[0-9]\|/\^\|\^GB\|$gb\|$gb_hash{$gb}/;
		 print OUTPUT1 $_;
                 $gb = '';
                 $rf = '';
	 }
	 else {
		 print OUTPUT1 $_;
	 }
}





close INPUT1;
close INPUT2;
close INPUT3;
close OUTPUT1;

