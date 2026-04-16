#!/bin/sh
if command -v docker >/dev/null 2>&1; then
  cd `dirname $0`
  id=$(docker create sflow/clab-sflow-rt)
  docker cp $id:/sflow-rt/app/browse-flows app
  docker cp $id:/sflow-rt/app/browse-metrics app
  docker cp $id:/sflow-rt/app/containerlab-dashboard app
  cd - > /dev/null
else
  echo "Requires docker"
fi
