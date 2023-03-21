FROM alpine:3.17 as build
RUN apk --update add \
      build-base \
      gcc \
      git \
      libpcap-dev \
      linux-headers \
 && git clone https://github.com/sflow/host-sflow.git \
 && cd host-sflow \
 && make FEATURES="PCAP" \
 && make install

FROM quay.io/frrouting/frr:8.5.0
LABEL maintainer="InMon Corp. https://inmon.com"
LABEL description="FRR and Host sFlow agent for CONTAINERlab"
LABEL url=https://hub.docker.com/r/sflow/clab-frr
COPY --from=build /usr/sbin/hsflowd /usr/sbin/hsflowd
COPY --from=build /etc/hsflowd/ /etc/hsflowd/
RUN apk add --no-cache dmidecode libpcap
ADD bgpd.conf /etc/frr/
ADD zebra.conf /etc/frr/
ADD vtysh.conf /etc/frr/
ADD daemons /etc/frr/
ADD start.sh /
ENTRYPOINT [ "/sbin/tini", "--", "/start.sh" ]
