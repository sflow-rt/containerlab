#!/bin/sh
if docker inspect -f '{{.State.Running}}' containerlab 2>&1 > /dev/null; then
  docker exec -it containerlab "./develop/python/$1"
else
  echo "containerlab no running"
fi
