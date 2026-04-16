// author: InMon
// version: 1.0
// date: April 15, 2026
// description: log tcp flows

setFlow('tcp', {
  keys:'ipsource,ipdestination,tcpsourceport,tcpdestinationport',
  value:'bytes',
  activeTimeout:10,
  log:true});

setFlowHandler(function(rec) {
  logInfo(JSON.stringify(rec));
}, ['tcp']);
