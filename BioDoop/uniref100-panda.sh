#!/usr/bin/bash

#clear up from the previous run
/opt/hadoop/bin/hadoop fs -rm /projects/uniref100/*


########
#Part 1#
########
# get the complete Uniprot in Hadoop
cat /usr/local/projects/DB/uniprotkb/uniprotkb_current/uniprot_sprot.dat /usr/local/projects/DB/uniprotkb/uniprotkb_current/uniprot_trembl.dat  | /opt/hadoop/bin/hadoop fs -put - /projects/uniref100/uniprot_sprot_trembl.dat

# parsing the additional cross-references from Hadoop
/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /projects/uniref100/uniprot_sprot_trembl.dat -output /projects/uniref100/uniprot_addtl_cxrefs -mapper /usr/local/devel/BCIS/commonDB/uniprot_addtl_cxrefs_map.rb -file /usr/local/devel/BCIS/commonDB/uniprot_addtl_cxrefs_map.rb

# save output and delete input file
/opt/hadoop/bin/hadoop fs -rm /projects/uniref100/uniprot_sprot_trembl.dat
/opt/hadoop/bin/hadoop fs -cat /projects/uniref100/uniprot_addtl_cxrefs/part-* | gunzip > /usr/local/projects/DB/uniprot_addtl_cxrefs



########
#Part 2#
########
# get the data that will be used to aggregate for the Uniref100 cluster members and their taxons
cut -f 1,9,14 /usr/local/projects/DB/uniprotkb/uniprotkb_current/idmapping_selected.tab | /opt/hadoop/bin/hadoop fs -put - /projects/uniref100/uniref100_clusters_pre

# compute the clusters in Hadoop via a distributed sorting
/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /projects/uniref100/uniref100_clusters_pre -output /projects/uniref100/uniref100_clusters -file /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_map.rb  -mapper /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_map.rb -file /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_reduce.rb -reducer /usr/local/devel/BCIS/commonDB/uniprot_taxon_clusters_reduce.rb -numReduceTasks 128

# keep only the cross-references that are specific to Uniref100 (Uniprot is a super-set of Uniref100) 
/opt/hadoop/bin/hadoop fs -cat /projects/uniref100/uniref100_clusters/part-*  | gunzip | /usr/local/devel/BCIS/commonDB/uniprot_addtl_cxrefs_cluster.pl /usr/local/projects/DB/uniprotkb/uniprotkb_current/idmapping.dat /usr/local/projects/DB/uniprot_addtl_cxrefs | /opt/hadoop/bin/hadoop fs -put - /projects/uniref100/uniprot_addtl_cxrefs_uniref100



########
#Part 3#
########
#put the cross-references in Hadoop
/opt/hadoop/bin/hadoop fs -put /usr/local/projects/DB/uniprotkb/uniprotkb_current/idmapping.dat /projects/uniref100

#run sorting of cross-references and Uniref100 cluster data
/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /usr/local/projects/DB/uniprotkb/uniprotkb_current/idmapping.dat -input /projects/uniref100/uniprot_addtl_cxrefs_uniref100 -input /projects/uniref100/uniref100_clusters -output /projects/uniref100/uniref_clusters_map_current_pre -mapper /usr/local/devel/BCIS/commonDB/uniprot_sort.rb -file  /usr/local/devel/BCIS/commonDB/uniprot_sort.rb -numReduceTasks 128

#copy final output file to common DBs directory
/opt/hadoop/bin/hadoop fs -cat /projects/uniref100/uniref_clusters_map_current/part-* | gunzip > /usr/local/projects/DB/uniref_clusters_map_temp


########
#Part 4#
########
#upload to the MySQL database (to a table that will be renamed in further steps, so production pipelines do not get affected)
mysql -h mysql-lan-pro -P3306 -u ifx_commonDB_adm -p19700101 --execute='create table uniref_clusters_map_temp (uniref_identifier char(8), external_db_name varchar(64), external_db_identifier varchar(512))'
mysqlimport -h mysql-lan-pro -P3306 -u ifx_commonDB_adm -p19700101 --local ifx_commonDB /usr/local/projects/DB/uniref_clusters_map_temp

#create MySQL indexes - the most time consuming part!
mysql -h mysql-lan-pro -P3306 -u ifx_commonDB_adm -p19700101 --execute='drop index ix_uniref_clusters_map'
mysql -h mysql-lan-pro -P3306 -u ifx_commonDB_adm -p19700101 --execute='create index ix_uniref_clusters_map on uniref_clusters_map_temp (uniref_identifier,external_db_name)'



#clean up
/opt/hadoop/bin/hadoop fs -rm /projects/uniref100/*
rm /usr/local/projects/DB/uniprot_addtl_cxrefs

#rename the tables and get the latest version in production
month=`date +%m`
last_month=`expr $month - 1`
last_month_date=$last_month`date +%d%Y`

mysql -h mysql-lan-pro -P3306 -u ifx_commonDB_adm -p19700101 --execute='RENAME TABLE uniref_clusters_map_current uniref_clusters_map_'$last_month_date
mysql -h mysql-lan-pro -P3306 -u ifx_commonDB_adm -p19700101 --execute='RENAME TABLE uniref_clusters_map_temp uniref_clusters_map_current'
