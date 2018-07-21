#!/bin/bash

CLUSTER_NAME=swarm-box
MASTERS=2
WORKERS=2

#destroy workers
for ((i=0; i<$WORKERS; i++))
do
	docker-machine rm $CLUSTER_NAME-w$i -y
done

#destroy masters
for ((i=0; i<$MASTERS; i++))
do
	docker-machine rm $CLUSTER_NAME-m$i -y
done

echo "done"