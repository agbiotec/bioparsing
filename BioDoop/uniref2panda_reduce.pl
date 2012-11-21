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

my ( $unirefID, $unirefHEAD, $unirefCluster, $unirefTaxon, $isoform, @isoformData, $newHeader, $misc, $sequence, $emblID, $giID, $key, $value, $uniref_entry_flag, $id_mapping_flag);

$uniref_entry_flag = 0;
$id_mapping_flag = 0;
$unirefHEAD = '';
$sequence = ''; 
$giID = '';
$emblID = '';


    while (<STDIN>) {



        if ($uniref_entry_flag == 1 and $id_mapping_flag ==1) {
            
	    $uniref_entry_flag = 0;
	    $id_mapping_flag = 0;

            #NEED taxon:TAXID HERE FROM THE GI - NCBI TAXID MAPPING
            if ($isoform eq "") {
	        $newHeader = ">$giID|$emblID $unirefCluster taxon: {$unirefTaxon;} $misc";
	       }

            else {
	        $newHeader = ">$giID|$emblID|$isoform $unirefCluster taxon: {$unirefTaxon;} $misc";
	       }

	    print "$newHeader\n$sequence\n";


        }



            #$unirefHEAD = '';
            #$giID = '';
            #$emblID = '';


        chomp $_;
	($key,$value) = split(/\t/, $_);
 

	if ($_=~ /.*@@@.*/) {
            ($unirefHEAD,$sequence) =  split(/@@@/,$value);
	}

	elsif ($_=~ /.*---.*/) {
            ($giID,$emblID) = split(/---/,$value);
        }

      
       
        # If the line is a uniref header
        if ( length($unirefHEAD) > 1 and $uniref_entry_flag == 0 ) {


            # Use regex to acquire the following:
            $unirefHEAD =~ m/>([A-Za-z0-9]+)_([A-Za-z0-9-]+) (.+) n=\d+ Tax=(.+) RepID.*/;
	    $unirefID = $2;                                                      # UniRef ID
            $unirefCluster = $3;                                                 # UniRef Cluster name.
            $unirefTaxon = $4;                                                   # UniRef Taxon name.
           
            $isoform = "";
            @isoformData = split('-',$unirefID);
            if (scalar(@isoformData) > 1) {
                    $isoform = $isoformData[1];
                    $unirefID = $isoformData[0];
                }
																				            
            $uniref_entry_flag = 1;

            }



        # line is a uniref id mapping header
        elsif ( length($giID) > 1 ) {

	     # Intialize the remaining tags. Set wgp, cg, and closed to 1 if the EMBL ID starts with any of appropriate letters.
	     $misc = "(exp=0; wgp=0; cg=0; closed=0; pub=1; rf_status =;)";
             $misc = "(exp=0; wgp=1; cg=1; closed=1; pub=1; rf_status =;)" if ($emblID =~ m/^(AL|BX|CR|CT|CU).*/);

             $id_mapping_flag = 1;

	}



            
    }
