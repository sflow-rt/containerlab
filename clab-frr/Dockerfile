FROM alpine:3.20 AS build
RUN apk --update add \
      build-base \
      gcc \
      git \
      libpcap-dev \
      linux-headers \
 && git clone https://github.com/sflow/host-sflow.git \
 && cd host-sflow \
 && sed -i 's/#define SFL_INTERNAL_INTERFACE 0x3FFFFFFF/#define SFL_INTERNAL_INTERFACE 0/g' src/sflow/sflow.h \
 && make FEATURES="PCAP" \
 && make install

FROM quay.io/frrouting/frr:10.2.3
LABEL maintainer="InMon Corp. https://inmon.com"
LABEL description="FRR and Host sFlow agent for CONTAINERlab"
LABEL url=https://hub.docker.com/r/sflow/clab-frr
COPY --from=build /usr/sbin/hsflowd /usr/sbin/hsflowd
COPY --from=build /etc/hsflowd/ /etc/hsflowd/
RUN apk add --no-cache dmidecode libpcap
ADD frr.conf vtysh.conf daemons /etc/frr/
ADD start.sh /
ENTRYPOINT [ "/sbin/tini", "--", "/start.sh" ]
