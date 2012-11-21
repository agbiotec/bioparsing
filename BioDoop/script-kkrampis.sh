#!/usr/local/bin/bash
#push data to hadoop server
zcat /usr/local/scratch/METAGENOMICS/jgoll/uniprot/uniprot_sprot.dat.gz /usr/local/scratch/METAGENOMICS/jgoll/uniprot/uniprot_trembl.dat.gz  | /opt/hadoop/bin/hadoop fs -put - /user/kkrampis/panda-test/uniprot_sprot_trembl.dat

/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /user/kkrampis/panda-test/uniprot_sprot_trembl.dat -output /user/kkrampis/panda-test/uniprot_addtl_cxrefs -mapper "ruby /usr/local/devel/BCIS/commonDB/uniprot_addtl_cxrefs_map.rb" -file /usr/local/devel/BCIS/commonDB/uniprot_addtl_cxrefs_map.rb

# save output and delete input file
#/opt/hadoop/bin/hadoop fs -rm /user/kkrampis/panda-test/uniprot_sprot_trembl.dat
/opt/hadoop/bin/hadoop fs -cat /user/kkrampis/panda-test/uniprot_addtl_cxrefs/part-* | gunzip > /usr/local/projects/DB/uniprot_addtl_cxrefs



########
#Part 2#
########
# get the data that will be used to aggregate for the Uniref100 cluster members and their taxons
cut -f 1,9,14 /usr/local/projects/DB/uniprotkb/uniprotkb_current/idmapping_selected.tab | /opt/hadoop/bin/hadoop fs -put - /user/kkrampis/panda-test/uniref100_clusters_pre

# compute the clusters in Hadoop via a distributed sorting
/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /user/kkrampis/panda-test/uniref100_clusters_pre -output /user/kkrampis/panda-test/uniref100_clusters -file /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_map.rb -mapper "ruby /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_map.rb" -file /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_reduce.rb -reducer "ruby /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_reduce.rb" -numReduceTasks 128

# keep only the cross-references that are specific to Uniref100 (Uniprot is a super-set of Uniref100)
/opt/hadoop/bin/hadoop fs -cat /user/kkrampis/panda-test/uniref100_clusters/part-* | gunzip | /usr/local/devel/BCIS/commonDB/uniprot_addtl_cxrefs_cluster.pl /usr/local/projects/DB/uniprotkb/uniprotkb_current/idmapping.dat /usr/local/projects/DB/uniprot_addtl_cxrefs | /opt/hadoop/bin/hadoop fs -put - /user/kkrampis/panda-test/uniprot_addtl_cxrefs_uniref100



########
#Part 3#
########
#put the cross-references in Hadoop
/opt/hadoop/bin/hadoop fs -put /usr/local/projects/DB/uniprotkb/uniprotkb_current/idmapping.dat /user/kkrampis/panda-test/

#run sorting of cross-references and Uniref100 cluster data
/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /user/kkrampis/panda-test/idmapping.dat -input /user/kkrampis/panda-test/uniprot_addtl_cxrefs_uniref100 -input /user/kkrampis/panda-test/uniref100_clusters -output /user/kkrampis/panda-test/uniref_clusters_map_current -mapper "ruby /usr/local/devel/BCIS/commonDB/uniprot_sort.rb" -file /usr/local/devel/BCIS/commonDB/uniprot_sort.rb -numReduceTasks 128

#copy final output file to common DBs directory
/opt/hadoop/bin/hadoop fs -cat /user/kkrampis/panda-test/uniref_clusters_map_current/part-* | gunzip > /usr/local/projects/DB/uniref_clusters_map_temp


