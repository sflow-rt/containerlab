#!/bin/sh
if command -v docker >/dev/null 2>&1; then
  cd `dirname $0`
  docker run --rm -v $PWD/app/:/sflow-rt/app/ --entrypoint /sflow-rt/get-app.sh --user $(id -u):$(id -g) sflow/clab-sflow-rt $@
  cd - > /dev/null
else
  echo "Requires docker"
fi
