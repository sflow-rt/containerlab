// author: InMon
// version: 1.0
// date: April 15, 2026
// description: periodically report top tcp flows

setFlow('tcp', {
  keys:'ipsource,ipdestination,tcpsourceport,tcpdestinationport',
  value:'bytes'});

setIntervalHandler(function(now) {
  logInfo(new Date(now));
  activeFlows('ALL','tcp').forEach((flow) => logInfo(JSON.stringify(flow)));
}, 5);
