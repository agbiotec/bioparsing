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

my ( $unirefID, $unirefHEAD, $unirefCluster, $unirefTaxon, $isoform, @isoformData, $newHeader, $misc, $sequence, $crossIDs, $taxonID, $key, $value, $uniref_entry_flag, $cross_refs_flag, $kingdom_flag, $clusters_flag,@cluster_members, $members_taxons, $cluster_ids, $kingdom);

$uniref_entry_flag = 0;
$cross_refs_flag = 0;
$kingdom_flag = 0;
$clusters_flag = 0;


    while (<STDIN>) {



        if ($uniref_entry_flag == 1 and $cross_refs_flag == 1 and $kingdom_flag == 1 and $clusters_flag = 1) {
            
	    $uniref_entry_flag = 0;
            $cross_refs_flag = 0;
            $kingdom_flag = 0;
            $clusters_flag = 0;

            #NEED taxon:TAXID HERE FROM THE GI - NCBI TAXID MAPPING
            if ($isoform eq "") {
	        $newHeader = ">SP|$unirefID^|^$crossIDs^|^$cluster_ids^|^$members_taxons\@\@\@$kingdom $unirefCluster taxon:$taxonID {$unirefTaxon} $misc ";
	       }

            else {
	        $newHeader = ">SP|$unirefID^|^$crossIDs^|^$cluster_ids^|^$members_taxons^|^$isoform\@\@\@$kingdom $unirefCluster taxon:$taxonID {$unirefTaxon} $misc ";
	       }

	    print "$newHeader\n$sequence\n";

 
        }




        chomp $_;
	($key,$value) = split(/\t/, $_);

      
       
        # If the line is a uniref header
        #if ( length($unirefHEAD) > 1 and $uniref_entry_flag == 0 ) {
         #if ($key =~ s/-1//) {
         if ($value =~ s/-1$//) {

            ($unirefHEAD,$sequence) =  split(/@@@/,$value);

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
         #elsif ($key =~ s/-2//) {
         elsif ($value =~ s/-2$//) {


	     # Intialize the remaining tags. Set wgp, cg, and closed to 1 if the EMBL ID starts with any of appropriate letters.
	     $misc = "(exp=0; wgp=0; cg=0; closed=0; pub=1; rf_status =;)";

             if ($value =~ s/---//) {
                 $misc = "(exp=0; wgp=1; cg=1; closed=1; pub=1; rf_status =;)";
             }

             $value =~ /\^\|\^Taxon\|([0-9]+)/;
	     $taxonID = $1;
             $value =~ s/\^\|\^Taxon\|[0-9]+//;
	     $crossIDs = $value;
	     $cross_refs_flag = 1;

	    }

         #elsif ($key =~ s/-3// ) {
         elsif ($value =~ s/-3$// ) {

		 $kingdom = $value;
		 $kingdom_flag = 1;
	    }
            

         #elsif ($key =~ s/-4// ) {
         elsif ($value =~ s/-4$// ) {

		 ($members_taxons,$cluster_ids) = split(/---/,$value);
		 $members_taxons =~ s/^,//;
		 $members_taxons = "Cluster_Taxons|$members_taxons";

                 @cluster_members = split(/,/,$cluster_ids);
		 $cluster_ids = '';
                 foreach(@cluster_members) {
			if (length($_)>0) { 
		            $cluster_ids = $cluster_ids.'SP|'.$_.'^|';		
                        }
		 }
                 
		 $cluster_ids =~ s/\^\|$//;
	         $clusters_flag = 1;

	    }
            
   } 



        #need that for after processing the last trio of records 
   

        if ($uniref_entry_flag == 1 and $cross_refs_flag == 1 and $kingdom_flag == 1 and $clusters_flag = 1 ) {
            
	    $uniref_entry_flag = 0;
            $cross_refs_flag = 0;
            $kingdom_flag = 0;
            $clusters_flag = 0;

            if ($isoform eq "") {
	        $newHeader = ">SP|$unirefID^|^$crossIDs^|^$cluster_ids^|^$members_taxons\@\@\@$kingdom $unirefCluster taxon:$taxonID {$unirefTaxon} $misc";
	    }   

            else {
	        $newHeader = ">SP|$unirefID^|^$crossIDs^|^$cluster_ids^|^$members_taxons^|^$isoform\@\@\@$kingdom $unirefCluster taxon:$taxonID {$unirefTaxon} $misc";
	       }

	    print "$newHeader\n$sequence\n";

            #$unirefHEAD = '';
            #$giID = '';
}
