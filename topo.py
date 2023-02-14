#!/usr/bin/env python3

# Post Containerlab topology to sflow-rt
# ./topo.py clab-clos3

import sys
from json import load, dumps
from urllib.request import build_opener, HTTPHandler, Request

with open(sys.argv[1] + '/topology-data.json') as f:
  contents = load(f)
collector = '127.0.0.1'
router_image = 'sflow/clab-frr'
rt_links = {}
link_no = 1
nodes = contents['nodes']
def is_fabric_link(link):
  if nodes[link['node1']]['image'] != router_image:
    return False
  if nodes[link['node2']]['image'] != router_image:
    return False
  return True
for link in contents['links']:
  rt_link = {
    'node1': link['a']['node'],
    'port1': link['a']['interface'],
    'node2': link['z']['node'],
    'port2': link['z']['interface']
  }
  if is_fabric_link(rt_link):
    rt_links['link%i' % link_no] = rt_link
    link_no = link_no + 1
rt_topo = {'links':rt_links}

opener = build_opener(HTTPHandler)
request = Request('http://%s:8008/topology/json' % collector, data=dumps(rt_topo).encode('utf-8'))
request.add_header('Content-Type','application/json')
request.get_method = lambda: 'PUT'
url = opener.open(request)
