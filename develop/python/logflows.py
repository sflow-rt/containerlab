#!/usr/bin/env python3
import signal
import requests
import json

def sig_handler(signal,frame):
  requests.delete('http://127.0.0.1:8008/flow/tcp/json')
  exit(0)
signal.signal(signal.SIGINT, sig_handler)

flow = {'keys':'ipsource,ipdestination,tcpsourceport,tcpdestinationport',
 'value':'bytes','activeTimeout':10, 'log':True}
requests.put('http://127.0.0.1:8008/flow/tcp/json',data=json.dumps(flow))

flowurl = 'http://127.0.0.1:8008/flows/json?name=tcp&maxFlows=10&timeout=60'
flowID = -1
while True:
  r = requests.get(flowurl + "&flowID=" + str(flowID))
  if r.status_code != 200: break
  flows = r.json()
  if len(flows) == 0: continue

  flowID = flows[0]["flowID"]
  flows.reverse()
  for f in flows:
    print(json.dumps(f))
