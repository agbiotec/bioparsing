#!/usr/bin/perl
###########################################################################
# $Id: uniref2panda.pl 1 2010-07-08 10:39:00Z rsanka $
#
# Description: Converts input fasta file with UniRef headers to fasta file
#              with PANDA headers. 
#
# Original version by Ravi
# Hadoop-fied by Ntino
###########################################################################

##looses one record in the beginning and one in the end

use strict;
use warnings;

my ($line, @line_split, $unirefID, $unirefHEAD, $unirefID_to_emit, $unirefHEAD_to_emit, $sequence, $sequence_to_emit, $emblID, $giID, $taxon_id, $map_value, $uniref_entry_flag, $id_mapping_flag, $taxon_mapping_flag);

$sequence = '';
$uniref_entry_flag = 0;
$id_mapping_flag = 0;
$taxon_mapping_flag = 0;

    # Parse each line of input fasta file. 

    while (<STDIN>) {



        if ($uniref_entry_flag == 1) {
            
	    $uniref_entry_flag = 0;

	    #we're done with the sequence gathering rounds for a record, 
            #emit key-value before we start working on a new record 
		
            #we will need the Uniref header for the convertion during the reduce step
	    $map_value = $unirefHEAD.'---'.$sequence;
	    print "$unirefID-1\t$map_value\n";

        }


        if ( $id_mapping_flag == 1) {
            
	    $id_mapping_flag = 0;

	    $map_value = $giID.'---'.$emblID;
	    print "$unirefID-2\t$map_value\n";

        }


        if ( $taxon_mapping_flag == 1) {
            
	    $taxon_mapping_flag = 0;

	    print "$unirefID-3\t$taxon_id\n";

        }


        chomp $_;
        @line_split = split(/\t/,$_);

        
        # If the line is a uniref header
        if ($_ =~ /^>/) {


	    $unirefHEAD = $line_split[0];
	    $sequence = $line_split[1];
            $unirefHEAD =~ m/>([A-Za-z0-9]+)_([A-Za-z0-9-]+) (.+) n=\d+ Tax=(.+) RepID.*/;
            $unirefID = $2;                       
	    $uniref_entry_flag = 1;
 
            }



        # line is a uniref id mapping header
        elsif ( ($line_split[1] eq 'GI') || ($line_split[1] eq 'EMBL') ){

            $unirefID = $line_split[0];

	    if ($line_split[1] eq 'GI') {
		    $giID = $line_split[2];
            } 
	     
	    if ($line_split[1] eq 'EMBL') {
		    $emblID = $line_split[2];
		    $id_mapping_flag = 1;
            } 

	}

        elsif ( $line_split[1] eq 'TAXON' ){

            $unirefID = $line_split[0];
	    $taxon_id = $line_split[2];
	    $taxon_mapping_flag = 1;	
	}



            
    }



    #last line after the map streaming is over

        if ($uniref_entry_flag == 1) {
            
	    $uniref_entry_flag = 0;

	    #we're done with the sequence gathering rounds for a record, 
            #emit key-value before we start working on a new record 
		
            #we will need the Uniref header for the convertion during the reduce step
	    $map_value = $unirefHEAD.'---'.$sequence;
	    print "$unirefID-1\t$map_value\n";

        }


        if ( $id_mapping_flag == 1) {
            
	    $id_mapping_flag = 0;

	    $map_value = $giID.'---'.$emblID;
	    print "$unirefID-2\t$map_value\n";

        }


        if ( $taxon_mapping_flag == 1) {
            
	    $taxon_mapping_flag = 0;

	    print "$unirefID-3\t$taxon_id\n";

        }

