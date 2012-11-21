#!/bin/bash

/opt/hadoop/bin/hadoop fs -mkdir /user/$USER/workshop 

/opt/hadoop/bin/hadoop fs -put /home/cloud/training/uniref100_proteins /user/$USER/workshop 

/opt/hadoop/bin/hadoop fs -ls /user/$USER/workshop


/opt/hadoop/bin/hadoop jar /opt/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar -input /user/$USER/workshop/uniref100_proteins -output /user/$USER/workshop/uniref100_clusters  -file /home/cloud/training/uniref100_clusters_map.rb  -mapper /home/cloud/training/uniref100_clusters_map.rb -file /home/cloud/training/uniref100_clusters_reduce.rb -reducer /home/cloud/training/uniref100_clusters_reduce.rb

sleep 30

/opt/hadoop/bin/hadoop fs -get /user/$USER/workshop/uniref100_clusters /home/cloud/users/$USER

ls -lh /home/cloud/users/$USER/uniref100_clusters/
gunzip /home/cloud/users/$USER/uniref100_clusters/part-00000.gz
more /home/cloud/users/$USER/uniref100_clusters/part-00000

/opt/hadoop/bin/hadoop fs -rmr /user/$USER/workshop
