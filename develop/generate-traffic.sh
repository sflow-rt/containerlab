#!/bin/sh
COUNT=${1:-1}
SLEEP=${2:-10}
TARGET=${3:-172.16.2.2}
if docker inspect -f '{{.State.Running}}' clab-develop-sflow-rt 2>&1 > /dev/null; then
  for i in $(seq $COUNT); do
    docker exec -it clab-develop-h1 iperf3 -c $TARGET
    if [ $i -ne $COUNT ]; then
      sleep $SLEEP
    fi
  done
else
  echo "run 'containerlab -t develop.yml'"
fi
