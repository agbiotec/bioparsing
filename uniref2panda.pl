#!/usr/local/bin/perl
###########################################################################
# $Id: uniref2panda.pl 1 2010-07-08 10:39:00Z rsanka $
#
# Description: Converts input fasta file with UniRef headers to fasta file
#              with PANDA headers. 
#
# Test and Debug Features:
#   Debug level 0  - All errors
#   Debug level 1  - Basic Application progress messages and warnings
#   Debug level 9  - Full Application progress messages (Verbose)
###########################################################################

# =============================== Pragmas ==================================
use strict;
use warnings;
use File::Basename;
use File::Path;
use File::Slurp;
use IO::File;
use DBI;
use TIGR::Foundation;
use TIGR::ConfigFile;

# =============================== Globals ==================================
my $HELPTEXT = qq~

  uniref2panda.pl [options]

    options:
      -uniref            Input fasta file with UniRef headers.
      -prefix            Prefix for output fasta file with PANDA headers.
      -db                Database name.
      -dbserver          Database server
      -dbusername        Database username
      -dbpassword        Database password
      -h                 Print this help message.
      -V                 Print the version information.

~;
my $VERSION = " Version 1.0 (Build " . (qw/$LastChangedRevision: 1 $/ )[1] . ")";     
my @DEPENDS = 
(
    "TIGR::Foundation"
);

my $tf = new TIGR::Foundation;

# =================================== Main ==================================
MAIN:
{
	my $uniref = "";                    # uniref option.
	my $prefix = "output";              # prefix option.
    my $db = "";                        # db option.
	my $dbserver = "";                  # dbserver option.
    my $dbusername = "";                # dbusername option.
    my $dbpassword = "";                # dbpassword option.
    
    # ========================== Program Setup ==============================
    $tf->addDependInfo(@DEPENDS);
    $tf->setHelpInfo($HELPTEXT);
    $tf->setVersionInfo($VERSION);

    # ========================== Handle User Options ========================
    my $result  = $tf->TIGR_GetOptions
                  (
                    'uniref=s',       \$uniref,
					'prefix=s',       \$prefix,
					'db=s',           \$db,
                    'dbserver=s',     \$dbserver,
					'dbusername=s',   \$dbusername,
                    'dbpassword=s',   \$dbpassword
                  );
    $tf->bail("Command line parsing failed") if ($result == 0);
    
    # Log name of uniref.
	if (defined $uniref) {
		$tf->logLocal("Using UniRef fasta file = '$uniref'", 9);
		if (!isReadableFile($uniref)) {
			$tf->bail("ERROR: Cannot read UniRef fasta file '$uniref'.");
		}
    }
	# Raise error if no uniref has been given.
	else {
        $tf->bail("ERROR: You must specify a UniRef fasta file!");
    }
    
	# Log prefix (if given).
	if (defined $prefix) {
        $tf->logLocal("Using prefix = '$prefix'", 9);
    }
    
    # Log name of db.
	if (defined $db) {
		$tf->logLocal("Using database = '$db'", 9);
    }
	# Raise error if no db has been given.
	else {
        $tf->bail("ERROR: You must specify a database name!");
    }
    
    # Log name of dbserver.
	if (defined $dbserver) {
		$tf->logLocal("Using database server = '$dbserver'", 9);
    }
	# Raise error if no dbserver has been given.
	else {
        $tf->bail("ERROR: You must specify a database server!");
    }
    
    # Log name of dbusername.
	if (defined $dbusername) {
		$tf->logLocal("Using database username = '$dbusername", 9);
    }
	# Raise error if no dbusername has been given.
	else {
        $tf->bail("ERROR: You must specify a database username!");
    }

    # Log name of dbpassword.
	if (defined $dbpassword) {
		$tf->logLocal("Using database password = '$dbpassword", 9);
    }
	# Raise error if no dbpassword has been given.
	else {
        $tf->bail("ERROR: You must specify a database password!");
    }

    my $debug_level = $tf->getDebugLevel();
    
    
	# ================ CONVERSION ==============================================================================
    my $panda = "$prefix.fasta";                   # Output PANDA fasta file.
    my $missing = $prefix."_missingIDs.fasta";     # Output PANDA fasta file of sequences missing 1 or more main IDs (GI, EMBL).
    my $missingList = "missing.txt";               # List of sequences missing any IDs (GI, EMBL, taxon).
    my $flag = 0;                                  # Signals which output file to write to (0 = main, 1 = missing).

    # Open filehandlers for all input and output files.
    my $uniref_fh = new IO::File "$uniref" or $tf->bail("ERROR: Cannot open UniRef fasta file $uniref");
    my $output_fh = new IO::File ">$panda" or $tf->bail("ERROR: Cannot open main output fasta file $panda");
    my $missing_fh = new IO::File ">$missing" or $tf->bail("ERROR: Cannot open missing output fasta file $missing");
    my $missingList_fh = new IO::File ">$missingList" or $tf->bail("ERROR: Cannot open missing output list $missingList");
    
    # Connect to DB.
    my $dbh = DBI->connect("dbi:mysql:ifx_commonDB;host=mysql51-lan-dev","ifx_commonDB","changeme",{RaiseError => 1});
    
    # Parse each line of input fasta file. 
    while (<$uniref_fh>) {
        chomp $_;
        my $line = $_;
        
        # If the line is a header, do the following:
        if ($line =~ /^>/) {
            $tf->logLocal("Starting header '$line'", 9);

            # Use regex to acquire the following:
            $line =~ m/>([A-Za-z0-9]+)_([A-Za-z0-9-]+) (.+) n=\d+ Tax=(.+) RepID.*/;
            my $unirefID = $2;                                                      # UniRef ID
            my $unirefCluster = $3;                                                 # UniRef Cluster name.
            my $unirefTaxon = $4;                                                   # UniRef Taxon name.
            my $origSeqName = "$1_$unirefID";                                       # original (UniRef) sequence name.
            
            my $isoform = "";
            my @isoformData = split('-',$unirefID);
            if (scalar(@isoformData) > 1) {
                $isoform = $isoformData[1];
                $unirefID = $isoformData[0];
            }
            
            $tf->logLocal("Starting sequence '$origSeqName'", 9);
            $tf->logLocal("  UniRef ID:            '$unirefID'", 9);
            $tf->logLocal("  UniRef Cluster Name:  '$unirefCluster'", 9);
            $tf->logLocal("  UniRef Taxon Name:    '$unirefTaxon'", 9);
            $tf->logLocal("  Isoform # (if any):   '$isoform'", 9);

            # Prepare query to get all rows with uniref_identifier is unirefID.
            my $query = "SELECT * FROM uniref_map WHERE uniref_identifier = '$unirefID'";
            $tf->logLocal("  Main IDs Query:  '$query'", 9);
            my $query_handle = $dbh->prepare($query);
            
            # Query execute.
            $query_handle->execute();
            
            # Bind table columns to variables.
            my ($uniID,$type,$ID);
            $query_handle->bind_columns(undef, \$uniID, \$type, \$ID);
            
            # Loop through results to acquire GI and EMBL IDs.
            my $giID = "";
            my $emblID = "";
            while($query_handle->fetch()) {
                if ($type eq "GI") {
                    $giID = $ID;
                }
                elsif ($type eq "EMBL") {
                    $emblID = $ID;
                }
            }
            $tf->logLocal("  Final main IDs for '$origSeqName' (GI,EMBL): ('$giID','$emblID')", 9);
            
            # Intialize the remaining tags. Set wgp, cg, and closed to 1 if the EMBL ID starts with any of appropriate letters.
            my $misc = "(exp=0; wgp=0; cg=0; closed=0; pub=1; rf_status =;)";
            $misc = "(exp=0; wgp=1; cg=1; closed=1; pub=1; rf_status =;)" if ($emblID =~ m/^(AL|BX|CR|CT|CU).*/);
            
            # Acquire taxon ID if the sequence has GI ID.
            my $taxID = "";
            if ($giID ne "") {
                # Prepare query to get all tax_id values where gi is giID.
                $query = "SELECT tax_id FROM gi_taxid_prot WHERE gi = $giID";
                $query_handle = $dbh->prepare($query);
                
                # Query execute.
                $query_handle->execute();
                
                # Bind table columns to variables.
                my $taxID_col;
                $query_handle->bind_columns(undef, \$taxID_col);
                
                # Loop through results to acquire the taxon ID.
                while($query_handle->fetch()) {
                    $taxID = $taxID_col;
                }
            }
            $tf->logLocal("  Final taxon ID for '$origSeqName': '$taxID'", 9);
            
            # Adjust flag to proper output file.
            if (($giID eq "") or ($emblID eq "")) {
                $flag = 1;
            }
            else {
                $flag = 0;
            }
            
            # Note sequence's missing IDs in missingList file.
            if (($giID eq "") or ($emblID eq "") or ($taxID eq "")) {
                my @missingIDs;
                push(@missingIDs,"GI") if ($giID eq "");
                push(@missingIDs,"EMBL") if ($emblID eq "");
                push(@missingIDs,"TAXON") if ($taxID eq "");
                my $mString = join(",", @missingIDs);
                print $missingList_fh "$origSeqName missing '$mString'\n";
            }
            
            # Create the new header.
            my $newHeader = "";
            $giID = "NONE" if ($giID eq "");
            $emblID = "NONE" if ($emblID eq "");
            $taxID = "NONE" if ($taxID eq "");
            
            if ($isoform eq "") {
                $newHeader = "$giID|$emblID $unirefCluster taxon:$taxID {$unirefTaxon;} $misc";
            }
            else {
                $newHeader = "$giID|$emblID|$isoform $unirefCluster taxon:$taxID {$unirefTaxon;} $misc";
            }
            
            $tf->logLocal("  New Header for '$origSeqName': '$newHeader'", 9);

            # Print the new header to the appropriate output.
            if ($flag == 0) {
                print $output_fh ">$newHeader\n";
            }
            else {
                print $missing_fh ">$newHeader\n";
            }
        }
        # If the line is not a header, print it to the appropriate output.
        else {
            if ($flag == 0) {
                print $output_fh "$line\n";
            }
            else {
                print $missing_fh "$line\n";
            }
        }
    }

    $dbh->disconnect();

    $output_fh->close();
    $missing_fh->close();
    $missingList_fh->close();
    $uniref_fh->close();
}
