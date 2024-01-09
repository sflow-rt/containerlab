FROM alpine:3.19
LABEL maintainer="InMon Corp. https://inmon.com"
LABEL description="iperf3 for CONTAINERlab"
LABEL url=https://hub.docker.com/r/sflow/clab-iperf3
RUN apk add --no-cache iperf3 tini \
  && apk add --no-cache hping3 --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing
ENTRYPOINT ["/sbin/tini","--","iperf3","-s"]
