#!/bin/sh

COLLECTOR="${COLLECTOR:-172.20.20.1}"
POLLING="${POLLING:-30}"
SAMPLING="${SAMPLING:-1000}"
NEIGHBORS="${NEIGHBORS:-eth1 eth2}"
HOSTPORT="${HOSTPORT:-eth3}"
HOSTNET="${HOSTNET:-none}"
EVPNSRC="${EVPNSRC:-none}"

CONF='/etc/hsflowd.conf'

printf "sflow {\n" > $CONF
printf " sampling=$SAMPLING\n" >> $CONF
printf " polling=$POLLING\n" >> $CONF
printf " collector { ip=$COLLECTOR }\n" >> $CONF
for dev in ${NEIGHBORS}
do
 printf " pcap { dev=$dev }\n" >> $CONF
done
if [ "$HOSTNET" != "none" ]; then
  printf " pcap { dev=$HOSTPORT }\n" >> $CONF
fi
printf "}\n" >> $CONF

BGP=/etc/frr/bgpd.conf
ZEBRA=/etc/frr/zebra.conf
LOCAL_ADDR=`hostname -i`
LOCAL_AS="${LOCAL_AS:-65000}"
sed -i "s/LOCAL_AS/$LOCAL_AS/g" $BGP
for dev in ${NEIGHBORS}
do
 printf " neighbor $dev interface peer-group fabric\n" >> $BGP
done
printf " !\n" >> $BGP

if [ "$HOSTNET" == "evpn" ]; then 
  printf " address-family l2vpn evpn\n" >> $BGP
  printf "  neighbor fabric activate\n" >> $BGP
  if [ "$EVPNSRC" != "none" ]; then
    printf "  advertise-all-vni\n" >> $BGP
  fi
  printf " exit-address-family\n" >> $BGP
  printf " !\n" >> $BGP
  if [ "$EVPNSRC" != "none" ]; then
    printf " address-family ipv4 unicast\n" >> $BGP
    printf "  network $EVPNSRC/32\n" >> $BGP
    printf " exit-address-family\n" >> $BGP
    printf "!\n" >> $BGP
    printf "exit\n" >> $BGP
    printf "!\n" >> $BGP
  fi
else
  if [ "$HOSTNET" != "none" ]; then
    printf " address-family ipv4 unicast\n" >> $BGP
    printf "  redistribute connected route-map HOST_ROUTES\n" >> $BGP
    printf " exit-address-family\n" >> $BGP
    printf "!\n" >> $BGP
    printf "exit\n" >> $BGP
    printf "!\n" >> $BGP
    printf "route-map HOST_ROUTES permit 10\n" >> $BGP
    printf "  match interface $HOSTPORT\n" >> $BGP
    printf "exit\n" >> $BGP
    printf "!\n" >> $BGP

    printf "interface $HOSTPORT\n" >> $ZEBRA
    printf " ip address $HOSTNET\n" >> $ZEBRA
    printf "exit\n" >> $ZEBRA
    printf "!\n" >> $ZEBRA
  fi
fi

chown -R frr:frr /etc/frr

sysctl -w net.ipv4.fib_multipath_hash_policy=1

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

/usr/sbin/hsflowd
exec /usr/lib/frr/docker-start
