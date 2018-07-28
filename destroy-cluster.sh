#!/bin/bash

source setenv.sh

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