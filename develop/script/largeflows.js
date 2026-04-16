// author: InMon
// version: 1.0
// date: April 15, 2026
// description: report start of large tcp flows

setFlow('tcp', {
  keys:'ipsource,ipdestination,tcpsourceport,tcpdestinationport',
  value:'bytes'});

setThreshold('large-tcp', {metric:'tcp', value: 1000000/8, byFlow: true});

setEventHandler(function(event) {
  logInfo(JSON.stringify(event));
}, ['large-tcp']);
