FROM alpine:3.15
LABEL maintainer="InMon Corp. https://inmon.com"
LABEL description="iperf3 for CONTAINERlab"
LABEL url=https://hub.docker.com/r/sflow/clab-iperf3
RUN apk add --no-cache iperf3 tini
ENTRYPOINT ["/sbin/tini","--","iperf3","-s"]
