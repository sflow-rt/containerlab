#!/usr/bin/env python3

# Restrict inter-switch link bandwidth
# ./bw.py clab-clos3

import sys
from json import load
from subprocess import run

kbps = '10000'
with open(sys.argv[1] + '/topology-data.json') as f:
  contents = load(f)
router_image = 'sflow/clab-frr'
nodes = contents['nodes']
def is_fabric_link(link):
  if nodes[link['a']['node']]['image'] != router_image:
    return False
  if nodes[link['z']['node']]['image'] != router_image:
    return False
  return True
def limit(port):
  cmd = ['containerlab','tools','netem','set','-n',nodes[port['node']]['longname'],'-i',port['interface'],'--rate',kbps]
  run(cmd)
for link in contents['links']:
  if is_fabric_link(link):
    limit(link['a'])
    limit(link['z'])
