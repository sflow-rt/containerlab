# containerlab
Experiment with real-time network telemetry using [containerlab](https://containerlab.dev/) to simulate Clos (leaf/spine) fabrics.

* [Real-time telemetry from a 5 stage Clos fabric](https://blog.sflow.com/2022/02/real-time-telemetry-from-5-stage-clos.html)
* [Topology aware fabric analytics](https://blog.sflow.com/2022/02/topology-aware-fabric-analytics.html)
* [Real-time EVPN fabric visibility](https://blog.sflow.com/2022/03/real-time-evpn-fabric-visibility.html)
* [Containerlab DDoS testbed](https://blog.sflow.com/2022/03/containerlab-ddos-testbed.html)
* [DDoS attacks and BGP Flowspec responses](https://blog.sflow.com/2022/03/ddos-attacks-and-bgp-flowspec-responses.html)
* [BGP Remotely Triggered Blackhole (RTBH)](https://blog.sflow.com/2022/04/bgp-remotely-triggered-blackhole-rtbh.html)
* [SR Linux in Containerlab](https://blog.sflow.com/2022/07/sr-linux-in-containerlab.html)
* [Real-time flow analytics with Containerlab templates](https://blog.sflow.com/2023/02/real-time-flow-analytics-with.html)
* [Leaf and spine network emulation on Mac OS M1/M2 systems](https://blog.sflow.com/2023/05/leaf-and-spine-network-emulation-on-mac.html)
* [Containerlab dashboard](https://blog.sflow.com/2023/08/containerlab-dashboard.html)
* [Emulating congestion with Containerlab](https://blog.sflow.com/2024/09/emulating-congestion-with-containerlab.html)
* [AI network performance monitoring using containerlab](https://blog.sflow.com/2025/06/ai-network-performance-monitoring-using.html)

Get started (on a system running Docker):
```
git clone https://github.com/sflow-rt/containerlab.git
cd containerlab
./run-clab
```

## 5 Stage Clos Topology
![](clos5.png)

Deploy 5 stage Clos topology:

`containerlab deploy -t clos5.yml`

Upload topology to sFlow-RT:

`./topo.py clab-clos5`

Generate traffic between `h1` and `h4`:

`docker exec -it clab-clos5-h1 iperf3 -c 172.16.4.2`

`docker exec -it clab-clos5-h1 iperf3 -c 2001:172:16:4::2`

Connect to http://localhost:8008/ for analytics, see [Quickstart](https://sflow-rt.com/intro.php) for more information.

## 3 Stage Clos Topology
![](clos3.png)

Deploy 3 stage Clos topology:

`containerlab deploy -t clos3.yml`

Upload topology to sFlow-RT:

`./topo.py clab-clos3`

Generate traffic between `h1` and `h2`:

`docker exec -it clab-clos3-h1 iperf3 -c 172.16.2.2`

`docker exec -it clab-clos3-h1 iperf3 -c 2001:172:16:2::2`

Connect to http://localhost:8008/ for analytics, see [Quickstart](https://sflow-rt.com/intro.php) for more information.

# EVPN Topology
<img src="evpn3.png" width="600">

Deploy EVPN topology:

`containerlab deploy -t evpn3.yml`

Upload topology to sFlow-RT:

`./topo.py clab-evpn3`

Generate traffic between `h1` and `h2`:

`docker exec -it clab-evpn3-h1 iperf3 -c 172.16.10.2`

`docker exec -it clab-evpn3-h1 iperf3 -c 2001:172:16:10::2`

Connect to http://localhost:8008/ for analytics, see [Quickstart](https://sflow-rt.com/intro.php) for more information.

## RoCEv2 Topology

![](clos3.png)

Deploy RoCEv2 toplogy:

`containerlab deploy -t rocev2.yml`

Upload topology to sFlow-RT:

`./topo.py clab-rocev2`

Generate traffic between `h1` and `h2`:

`docker exec -it clab-rocev2-h1 hping3 exec rocev2.tcl 172.16.2.2 10000 500 100`

Connect to http://localhost:8008/ for analytics, see [Quickstart](https://sflow-rt.com/intro.php) for more information.

# DDoS Topology
![](ddos.png)

Deploy DDOS topology:

`containerlab deploy -t ddos.yml`

Simulate DDoS attack against `victim`:

`docker exec -it clab-ddos-attacker hping3 --flood --udp -k -a 198.51.100.1 -s 53 192.0.2.129`

Connect to http://localhost:8008/ for analytics, see [Quickstart](https://sflow-rt.com/intro.php) for more information.

# Nokia SR Linux
![](srlinux.png)

Deploy SR Linux topology:

`containerlab deploy -t srlinux.yml`

Simulate traffic:

`docker exec -it clab-srlinux-h1 iperf3 -c 172.16.2.2`

Connect to http://localhost:8008/ for analytics, see [Quickstart](https://sflow-rt.com/intro.php) for more information.
