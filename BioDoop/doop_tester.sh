#!/bin/bash


#for i in {1..25}
#do
#
#      /opt/hadoop/bin/hadoop fs -put /usr/local/scratch/kkrampis/uniref/uniref100_cluster_proteins_taxons /user/kkrampis/uniref2panda/uniref100_cluster_proteins_taxons$i &
#
#done

for i in {1..25}
do
     #/opt/hadoop/bin/hadoop job  -Dmapred.job.tracker=fog-0-1-1:9011 -kill job_201010141247_000$i
     #/opt/hadoop/bin/hadoop job  -Dmapred.job.tracker=fog-0-1-1:9011 -kill job_201010141247_00$i
     /opt/hadoop/bin/hadoop fs -rmr /user/kkrampis/uniref2panda/uniref100_cluster_proteins_taxons_output_$i 
     #/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /user/kkrampis/uniref2panda/uniref100_cluster_proteins_taxons -output /user/kkrampis/uniref2panda/uniref100_cluster_proteins_taxons_output_$i  -file /home/kkrampis/devel/BioDoop/uniref100_clusters_map.rb  -mapper /home/kkrampis/devel/BioDoop/uniref100_clusters_map.rb -file /home/kkrampis/devel/BioDoop/uniref100_clusters_reduce.rb -reducer /home/kkrampis/devel/BioDoop/uniref100_clusters_reduce.rb &

done
