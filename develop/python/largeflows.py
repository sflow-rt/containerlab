#!/usr/bin/env python3
import signal
import requests
import json

def sig_handler(signal,frame):
  requests.delete('http://127.0.0.1:8008/threshold/large-tcp/json')
  requests.delete('http://127.0.0.1:8008/flow/tcp/json')
  exit(0)
signal.signal(signal.SIGINT, sig_handler)

flow = {'keys':'ipsource,ipdestination,tcpsourceport,tcpdestinationport', 'value':'bytes'}
requests.put('http://127.0.0.1:8008/flow/tcp/json',data=json.dumps(flow))

threshold = {'metric':'tcp', 'value': 1000000/8, 'byFlow':True}
requests.put('http://127.0.0.1:8008/threshold/large-tcp/json',data=json.dumps(threshold))

eventurl = 'http://127.0.0.1:8008/events/json?thresholdID=large-tcp&maxEvents=10&timeout=60'
eventID = -1
while True:
  r = requests.get(eventurl + "&eventID=" + str(eventID))
  if r.status_code != 200: break
  events = r.json()
  if len(events) == 0: continue

  eventID = events[0]["eventID"]
  events.reverse()
  for e in events:
    print(json.dumps(e))
