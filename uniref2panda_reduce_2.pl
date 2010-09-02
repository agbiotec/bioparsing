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

my ( $unirefID, $unirefHEAD, $unirefCluster, $unirefTaxon, $isoform, @isoformData, $newHeader, $misc, $sequence, $emblID, $giID, $taxonID, $key, $value, $uniref_entry_flag);

$uniref_entry_flag = 0;


    while (<STDIN>) {



        if ($uniref_entry_flag == 1) {
            
	    $uniref_entry_flag = 0;

            #NEED taxon:TAXID HERE FROM THE GI - NCBI TAXID MAPPING
            if ($isoform eq "") {
	        $newHeader = ">$giID|$emblID $unirefCluster taxon:$taxonID {$unirefTaxon;} $misc $unirefID";
	       }

            else {
	        $newHeader = ">$giID|$emblID|$isoform $unirefCluster taxon:$taxonID {$unirefTaxon;} $misc $unirefID";
	       }

	    print "$newHeader\n$sequence\n";

            #$unirefHEAD = '';
            #$giID = '';

        }




        chomp $_;
	($key,$value) = split(/\t/, $_);

      
       
        # If the line is a uniref header
        #if ( length($unirefHEAD) > 1 and $uniref_entry_flag == 0 ) {
         if ($key =~ s/-1//) {

            ($unirefHEAD,$sequence) =  split(/---/,$value);

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
																				            

            }



        # line is a uniref id mapping header
         elsif ($key =~ s/-2//) {
        #elsif ( length($giID) > 1 and $key == $unirefHEADkey ) {

             ($giID,$emblID) = split(/---/,$value);

	     # Intialize the remaining tags. Set wgp, cg, and closed to 1 if the EMBL ID starts with any of appropriate letters.
	     $misc = "(exp=0; wgp=0; cg=0; closed=0; pub=1; rf_status =;)";
             $misc = "(exp=0; wgp=1; cg=1; closed=1; pub=1; rf_status =;)" if ($emblID =~ m/^(AL|BX|CR|CT|CU).*/);


	    }

         elsif ($key =~ s/-3// ) {

		 $taxonID = $value;
		 $uniref_entry_flag = 1;

	    }

            
   } 



        #need that for after processing the last trio of records 
   
        if ($uniref_entry_flag == 1)  {
            
	    $uniref_entry_flag = 0;

            #NEED taxon:TAXID HERE FROM THE GI - NCBI TAXID MAPPING
            if ($isoform eq "") {
	        $newHeader = ">$giID|$emblID $unirefCluster taxon:$taxonID {$unirefTaxon;} $misc";
	       }

            else {
	        $newHeader = ">$giID|$emblID|$isoform $unirefCluster taxon:$taxonID {$unirefTaxon;} $misc";
	       }

	    print "$newHeader\n$sequence\n";

            #$unirefHEAD = '';
            #$giID = '';
}
