#!/bin/bash

source setenv.sh

# create masters VMs
for ((i=0; i<$MASTERS; i++))
do
	docker-machine create $DM_OPTS $CLUSTER_NAME-m$i &
	pids[${i}]=$!
done
# create workers VMs
for ((i=0; i<$WORKERS; i++))
do
	docker-machine create $DM_OPTS $CLUSTER_NAME-w$i &
	pids[$((i+$MASTERS))]=$!
done
# wait for the VMs to start
for pid in ${pids[*]}; do
    wait $pid
done
echo "--- all VMs are online --------------------------------------------------"

# start swarm master
eval $(docker-machine env $CLUSTER_NAME-m0)
MASTER_IP=$(docker-machine ip $CLUSTER_NAME-m0)
docker swarm init --advertise-addr $MASTER_IP

# masters join swarm
SWARM_MASTER_TOKEN=$(docker swarm join-token manager -q)
for ((i=1; i<$MASTERS; i++))
do
	eval $(docker-machine env $CLUSTER_NAME-m$i)
	docker swarm join --token $SWARM_MASTER_TOKEN $MASTER_IP
done

# workers join swarm
SWARM_WORKER_TOKEN=$(docker swarm join-token worker -q)
for ((i=0; i<$WORKERS; i++))
do
	eval $(docker-machine env $CLUSTER_NAME-w$i)
	docker swarm join --token $SWARM_WORKER_TOKEN $MASTER_IP
done

echo "swarm ready ($MASTER managers $WORKERS workers)"
echo "to connect run: eval \$(docker-machine env $CLUSTER_NAME-m0)"