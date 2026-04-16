#!/bin/sh
if docker inspect -f '{{.State.Running}}' clab-develop-sflow-rt 2>&1 > /dev/null; then
  cd `dirname $0`
  echo "+=======================================+"
  echo "| Web interface, http://localhost:8008/ |"
  echo "| Type Cntr+C to exit                   |"
  echo "========================================+"
  docker exec -it clab-develop-sflow-rt /sflow-rt/start.sh -Dsystem.propertyFiles=sflow-rt.conf $@
  cd - > /dev/null
else
  echo "run 'containerlab -t develop.yml'"
fi
