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

my ($line, @line_split, $unirefID, $unirefHEAD, $unirefID_to_emit, $unirefHEAD_to_emit, $sequence, $sequence_to_emit, $kingdom_id, $map_value, $uniref_entry_flag, $id_mapping_flag, $kingdom_mapping_flag,$uniprot,$geneid,$refseq,$gi,$pdb,$go,$ipi,$pir,$taxon,$mim,$unigene,$embl,$ensembl,$cross_ref,$taxon_ids,$member_ids,$clusters_flag, @gids, @goids, @gbids, @rfids);

$sequence = '';
$uniref_entry_flag = 0;
$id_mapping_flag = 0;
$kingdom_mapping_flag = 0;
$clusters_flag = 0;
$uniprot='';
$geneid='';
$refseq='';
$gi='';
$pdb='';
$go='';
$ipi='';
$pir='';
$taxon='';
$mim='';
$unigene='';
$embl='';
$ensembl='';

    # Parse each line of input fasta file. 

    while (<STDIN>) {



        if ($uniref_entry_flag == 1) {
            
	    $uniref_entry_flag = 0;

	    #we're done with the sequence gathering rounds for a record, 
            #emit key-value before we start working on a new record 
		
            #we will need the Uniref header for the convertion during the reduce step
	    $map_value = $unirefHEAD.'@@@'.$sequence;
	    #print "$unirefID-1\t$map_value\n";
	    print "$unirefID\t$map_value-1\n";

        }


        if ( $id_mapping_flag == 1) {
            
	    $id_mapping_flag = 0;
	    $map_value = 'UniProt|'.$uniprot;

            if (length($geneid)>0) {
		    $map_value = $map_value.'^|^EntrezGene|'.$geneid;
	    }
            if (length($refseq)>0) {
		    @rfids = split(/ /,$refseq);
		    $refseq = '';
		    foreach(@rfids) {
                        $_=~ s/\s//;
                        $refseq = 'RF|'.$_.'^|'.$refseq; 
		    }
		    $refseq =~ s/\^\|$//;
         	    $map_value = $map_value.'^|^'.$refseq;
	    }
            if (length($gi)>0) {
		    @gids = split(/ /,$gi);
		    $gi = '';
		    foreach(@gids) {
                        $_=~ s/\s//;
                        $gi = 'GI|'.$_.'^|'.$gi; 
		    }
		    $gi =~ s/\^\|$//;
         	    $map_value = $map_value.'^|^'.$gi;
	    }
            if (length($pdb)>0) {
		    $map_value = $map_value.'^|^PDB|'.$pdb;
	    }
            if (length($go)>0) {
		    @goids = split(/ /,$go);
		    $go = '';
		    foreach(@goids) {
                        $_=~ s/\s//;
                        $_=~ s/GO://;
                        $go = 'GO|'.$_.'^|'.$go; 
		    }
		    $go =~ s/\^\|$//;
         	    $map_value = $map_value.'^|^'.$go;
	    }
            if (length($ipi)>0) {
		    $map_value = $map_value.'^|^IPI|'.$ipi;
	    }
            if (length($pir)>0) {
		    $map_value = $map_value.'^|^PIR|'.$pir;
	    }
            if (length($taxon)>0) {
		    $map_value = $map_value.'^|^Taxon|'.$taxon;
	    }
            if (length($mim)>0) {
		    $map_value = $map_value.'^|^OMIM|'.$mim;
	    }
            if (length($unigene)>0) {
		    $map_value = $map_value.'^|^UniGene|'.$unigene;
	    }
            if (length($embl)>0 and ($embl =~ m/^(AL|BX|CR|CT|CU).*/)) {
		    @gbids = split(/ /,$embl);
		    $embl = '';
		    foreach(@gbids) {
                        $_=~ s/\s//;
                        $embl = 'GB|'.$_.'^|'.$embl; 
		    }
		    $embl =~ s/\^|$//;
		    $map_value = $map_value.'^|^'.$embl.'---';
	    }
            if (length($embl)>0) {
		    @gbids = split(/ /,$embl);
		    $embl = '';
		    foreach(@gbids) {
                        $_=~ s/\s//;
                        $embl = 'GB|'.$_.'^|'.$embl; 
		    }
		    $embl =~ s/\^|$//;
		    $map_value = $map_value.'^|^'.$embl;
	    }
            if (length($ensembl)>0) {
		    $map_value = $map_value.'^|^ENSEMBL|'.$ensembl;
	    }

	    #print "$unirefID-2\t$map_value\n";
	    print "$unirefID\t$map_value-2\n";

            $uniprot='';
            $geneid='';
            $refseq='';
            $gi='';
            $pdb='';
	    $go='';
            $ipi='';
	    $pir='';
	    $taxon='';
            $mim='';
	    $unigene='';
            $embl='';
            $ensembl='';

        }


        if ( $kingdom_mapping_flag == 1) {
            
	    $kingdom_mapping_flag = 0;

	    #print "$unirefID-3\t$kingdom_id\n";
	    print "$unirefID\t$kingdom_id-3\n";

        }

        if ( $clusters_flag == 1) {
            
	    $clusters_flag = 0;

	    #print "$unirefID-4\t$taxon_ids---$member_ids\n";
	    print "$unirefID\t$taxon_ids---$member_ids-4\n";

        }



        # start working on parsing the lines of the file

        $line = $_;
        chomp $line;
        @line_split = split(/\t/,$line);

        
        # If the line is a uniref header
        if ($_ =~ /^>/) {


	    $unirefHEAD = $line_split[0];
	    $sequence = $line_split[1];
            $unirefHEAD =~ m/>([A-Za-z0-9]+)_([A-Za-z0-9-]+) (.+) n=\d+ Tax=(.+) RepID.*/;
            $unirefID = $2;                       
	    $uniref_entry_flag = 1;
 
            }



        # line is a uniref id mapping header
#        elsif ( ($line_split[1] eq 'GI') || ($line_split[1] eq 'EMBL') ){
#
#            $unirefID = $line_split[0];
#
#	    if ($line_split[1] eq 'GI') {
#		    $giID = $line_split[2];
#            } 
#	     
#	    if ($line_split[1] eq 'EMBL') {
#		    $emblID = $line_split[2];
#		    $id_mapping_flag = 1;
#            } 
#
#	}
#
        elsif ( $line_split[1] eq 'KINGDOM' ){

           $unirefID = $line_split[0];
	   $kingdom_id = $line_split[2];
	   $kingdom_mapping_flag = 1;

	   }

        elsif ( $line_split[1] eq 'CLUSTERS' ){

           $unirefID = $line_split[0];
	   $member_ids = $line_split[2];
	   $taxon_ids = $line_split[3];
	   $clusters_flag = 1;

	   }

	else {

           $unirefID = $line_split[0];


	   foreach (@line_split) {
                 
		   $cross_ref = $_;
		   
		   if ($cross_ref =~ s/UniProtKB-ID-//) {
			   $uniprot = $cross_ref; 
		   }
		   elsif ($cross_ref =~ s/GeneID-//) {
			   $geneid = $cross_ref; 
		   }
		   elsif ($cross_ref =~ s/RefSeq-//) {
			   $refseq = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/GI-//) {
			   $gi = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/PDB-//) {
			   $pdb = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/GO-//) {
			   $go = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/IPI-//) {
			   $ipi = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/PIR-//) {
			   $pir = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/Taxon-//) {
			   $taxon = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/MIM-//) {
			   $mim = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/UniGene-//) {
			   $unigene = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/EMBL-// and !($cross_ref =~ s/CDS//) ) {
			   $embl = $cross_ref;
		   }
		   elsif ($cross_ref =~ s/Ensembl-//) {
			   $ensembl = $cross_ref;
		   }

	   }

	   $id_mapping_flag = 1;

	}



            
    }



    #last line after the map streaming is over

        if ($uniref_entry_flag == 1) {
            
	    $uniref_entry_flag = 0;

	    #we're done with the sequence gathering rounds for a record, 
            #emit key-value before we start working on a new record 
		
            #we will need the Uniref header for the convertion during the reduce step
	    $map_value = $unirefHEAD.'@@@'.$sequence;
	    #print "$unirefID-1\t$map_value\n";
	    print "$unirefID\t$map_value-1\n";

        }



        if ( $id_mapping_flag == 1) {
            
	    $id_mapping_flag = 0;
	    $map_value = 'UniProt|'.$uniprot;

            if (length($geneid)>0) {
		    $map_value = $map_value.'^|^EntrezGene|'.$geneid;
	    }
            if (length($refseq)>0) {
		    @rfids = split(/ /,$refseq);
		    $refseq = '';
		    foreach(@rfids) {
                        $_=~ s/\s//;
                        $refseq = 'RF|'.$_.'^|'.$refseq; 
		    }
		    $refseq =~ s/\^\|$//;
         	    $map_value = $map_value.'^|^'.$refseq;
	    }
            if (length($gi)>0) {
		    @gids = split(/ /,$gi);
		    $gi = '';
		    foreach(@gids) {
                        $_=~ s/\s//;
                        $gi = 'GI|'.$_.'^|'.$gi; 
		    }
		    $gi =~ s/\^\|$//;
         	    $map_value = $map_value.'^|^'.$gi;
	    }
            if (length($pdb)>0) {
		    $map_value = $map_value.'^|^PDB|'.$pdb;
	    }
            if (length($go)>0) {
		    @goids = split(/ /,$go);
		    $go = '';
		    foreach(@goids) {
                        $_=~ s/\s//;
                        $_=~ s/GO://;
                        $go = 'GO|'.$_.'^|'.$go; 
		    }
		    $go =~ s/\^\|$//;
         	    $map_value = $map_value.'^|^'.$go;
	    }
            if (length($ipi)>0) {
		    $map_value = $map_value.'^|^IPI|'.$ipi;
	    }
            if (length($pir)>0) {
		    $map_value = $map_value.'^|^PIR|'.$pir;
	    }
            if (length($taxon)>0) {
		    $map_value = $map_value.'^|^Taxon|'.$taxon;
	    }
            if (length($mim)>0) {
		    $map_value = $map_value.'^|^OMIM|'.$mim;
	    }
            if (length($unigene)>0) {
		    $map_value = $map_value.'^|^UniGene|'.$unigene;
	    }
            if (length($embl)>0 and ($embl =~ m/^(AL|BX|CR|CT|CU).*/)) {
		    @gbids = split(/ /,$embl);
		    $embl = '';
		    foreach(@gbids) {
                        $_=~ s/\s//;
                        $embl = 'GB|'.$_.'^|'.$embl; 
		    }
		    $embl =~ s/\^|$//;
		    $map_value = $map_value.'^|^'.$embl.'---';
	    }
            if (length($embl)>0) {
		    @gbids = split(/ /,$embl);
		    $embl = '';
		    foreach(@gbids) {
                        $_=~ s/\s//;
                        $embl = 'GB|'.$_.'^|'.$embl; 
		    }
		    $embl =~ s/\^|$//;
		    $map_value = $map_value.'^|^'.$embl;
	    }
            if (length($ensembl)>0) {
		    $map_value = $map_value.'^|^ENSEMBL|'.$ensembl;
	    }

	    #print "$unirefID-2\t$map_value\n";
	    print "$unirefID\t$map_value-2\n";

            $uniprot='';
            $geneid='';
            $refseq='';
            $gi='';
            $pdb='';
	    $go='';
            $ipi='';
	    $pir='';
	    $taxon='';
            $mim='';
	    $unigene='';
            $embl='';
            $ensembl='';

                    }




        if ( $kingdom_mapping_flag == 1) {
            
	    $kingdom_mapping_flag = 0;

	    #print "$unirefID-3\t$kingdom_id\n";
	    print "$unirefID\t$kingdom_id-3\n";

        }


        if ( $clusters_flag == 1) {
            
	    $clusters_flag = 0;

	    #print "$unirefID-4\t$taxon_ids---$member_ids\n";
	    print "$unirefID\t$taxon_ids---$member_ids-4\n";

        }
