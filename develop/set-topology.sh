#!/bin/sh
if docker inspect -f '{{.State.Running}}' containerlab 2>&1 > /dev/null; then
  docker exec containerlab ./topo.py clab-develop
else
  echo "containerlab no running"
fi
