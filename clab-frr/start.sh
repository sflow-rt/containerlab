#!/bin/sh

COLLECTOR="${COLLECTOR:-none}"
POLLING="${POLLING:-30}"
SAMPLING="${SAMPLING:-1000}"
NEIGHBORS="${NEIGHBORS:-eth1 eth2}"
HOSTPORT="${HOSTPORT:-eth3}"
HOSTNET="${HOSTNET:-none}"
EVPNSRC="${EVPNSRC:-none}"
CTLRASN="${CTLASN:-none}"
FLOWSPEC="${FLOWSPEC:-no}"
RTBH="${RTBH:-none}"

CONF='/etc/hsflowd.conf'

printf "sflow {\n" > $CONF
printf " sampling=$SAMPLING\n" >> $CONF
printf " sampling.bps_ratio=0\n" >> $CONF
printf " polling=$POLLING\n" >> $CONF
if [ "$COLLECTOR" != "none" ]; then
  printf " collector { ip=$COLLECTOR }\n" >> $CONF
fi
for dev in ${NEIGHBORS}
do
  printf " pcap { dev=$dev }\n" >> $CONF
done
if [ "$HOSTNET" != "none" ]; then
  printf " pcap { dev=$HOSTPORT }\n" >> $CONF
fi
printf "}\n" >> $CONF

BGP=/etc/frr/frr.conf
LOCAL_ADDR=`hostname -i`
LOCAL_AS="${LOCAL_AS:-65000}"
sed -i "s/LOCAL_AS/$LOCAL_AS/g" $BGP
if [ "$RTBH" != "none" ]; then
  printf "neighbor fabric ebgp-multihop 255\n" >> $BGP
fi
for dev in ${NEIGHBORS}
do
  printf "neighbor $dev interface peer-group fabric\n" >> $BGP
done
if [ "$CTLASN" != "none" ]; then
  printf "neighbor $COLLECTOR remote-as $CTLASN\n" >> $BGP
  printf "neighbor $COLLECTOR port 1179\n" >> $BGP
  printf "neighbor $COLLECTOR timers connect 10\n" >> $BGP
  printf "\n" >> $BGP
fi
if [ "$FLOWSPEC" == "yes" ]; then
  printf "address-family ipv4 flowspec\n" >> $BGP
  printf "neighbor fabric activate\n" >> $BGP
  if [ "$CTLASN" != "none" ]; then 
    printf "neighbor $COLLECTOR activate\n" >> $BGP
  fi
  printf "exit-address-family\n" >> $BGP
fi
printf "\n" >> $BGP
if [ "$HOSTNET" == "evpn" ]; then 
  printf "address-family l2vpn evpn\n" >> $BGP
  printf "neighbor fabric activate\n" >> $BGP
  if [ "$EVPNSRC" != "none" ]; then
    printf "advertise-all-vni\n" >> $BGP
  fi
  printf "exit-address-family\n" >> $BGP
  printf "\n" >> $BGP
  if [ "$EVPNSRC" != "none" ]; then
    printf "address-family ipv4 unicast\n" >> $BGP
    printf "network $EVPNSRC/32\n" >> $BGP
    printf "exit-address-family\n" >> $BGP
    printf "\n" >> $BGP
    printf "exit\n" >> $BGP
    printf "\n" >> $BGP
  fi
else
  if [ "$HOSTNET" != "none" ]; then
    printf "address-family ipv4 unicast\n" >> $BGP
    printf "redistribute connected route-map HOST_ROUTES\n" >> $BGP
    if [ "$RTBH" != "none" ]; then
      printf "neighbor fabric route-map RTBH in\n" >> $BGP
    fi
    printf "exit-address-family\n" >> $BGP
    printf "\n" >> $BGP
    printf "address-family ipv6 unicast\n" >> $BGP
    printf "redistribute connected route-map HOST_ROUTES\n" >> $BGP
    printf "neighbor fabric activate\n" >> $BGP
    printf "exit-address-family\n" >> $BGP
    printf "\n" >> $BGP
    printf "exit\n" >> $BGP
    printf "\n" >> $BGP
    printf "route-map HOST_ROUTES permit 10\n" >> $BGP
    printf "match interface $HOSTPORT\n" >> $BGP
    printf "exit\n" >> $BGP
    printf "\n" >> $BGP
    printf "interface $HOSTPORT\n" >> $BGP
    printf "ip address $HOSTNET\n" >> $BGP
    if [ "HOSTNET6" != "none" ]; then
      printf "ipv6 address $HOSTNET6\n" >> $BGP
    fi
    printf "exit\n" >> $BGP
    printf "\n" >> $BGP
  else
    printf "address-family ipv6 unicast\n" >> $BGP
    printf "neighbor fabric activate\n" >> $BGP
    printf "exit-address-family\n" >> $BGP
    printf "\n" >> $BGP
    printf "exit\n" >> $BGP
    printf "\n" >> $BGP
  fi
fi
if [ "$RTBH" != "none" ]; then
  printf "bgp community-list standard BLACKHOLE seq 5 permit blackhole\n" >> $BGP
  printf "\n" >> $BGP
  printf "route-map RTBH permit 10\n" >> $BGP
  printf "match community BLACKHOLE\n" >> $BGP
  printf "set ip next-hop $RTBH\n" >> $BGP
  printf "exit\n" >> $BGP
  printf "\n" >> $BGP
  printf "route-map RTBH permit 20\n" >> $BGP
  printf "exit\n" >> $BGP
  printf "\n" >> $BGP
  printf "ip route $RTBH/32 Null0\n" >> $BGP
  printf "\n" >> $BGP
fi

chown -R frr:frr /etc/frr

sysctl -w net.ipv4.fib_multipath_hash_policy=1
sysctl -w net.ipv6.conf.all.forwarding=1

while [ ! -f /tmp/initialized ]; do sleep 1; done

if [ "$HOSTNET" == "evpn" ] && [ "$EVPNSRC" != "none" ]; then
  ip addr add $EVPNSRC/32 dev lo
  ip link add vxlan10 type vxlan id 10 dstport 0 local $EVPNSRC
  brctl addbr br10
  brctl addif br10 vxlan10
  brctl stp br10 off
  ip link set up dev br10
  ip link set up dev vxlan10
  brctl addif br10 $HOSTPORT
fi

if [ "$COLLECTOR" != "none" ]; then
  /usr/sbin/hsflowd
fi
exec /usr/lib/frr/docker-start
