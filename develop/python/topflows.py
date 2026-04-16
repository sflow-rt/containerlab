#!/usr/bin/env python3
import signal
import time
import requests
import json

def sig_handler(signal,frame):
  requests.delete('http://127.0.0.1:8008/flow/tcp/json')
  exit(0)
signal.signal(signal.SIGINT, sig_handler)

flow = {'keys':'ipsource,ipdestination,tcpsourceport,tcpdestinationport', 'value':'bytes'}
requests.put('http://127.0.0.1:8008/flow/tcp/json',data=json.dumps(flow))

while True:
  time.sleep(5)
  print(time.asctime())
  r = requests.get('http://127.0.0.1:8008/activeflows/ALL/tcp/json')
  if r.status_code != 200: break
  flows = r.json()
  for f in flows:
    print(json.dumps(f))
