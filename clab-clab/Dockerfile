ARG ALPINE_VERSION=3.19

FROM alpine:${ALPINE_VERSION} as alpine

FROM alpine as build
RUN apk add --no-cache bash curl docker-cli git openssh make iptables device-mapper e2fsprogs-extra go \
 && git clone https://github.com/srl-labs/containerlab.git \
 && cd containerlab \
 && make build

FROM alpine
LABEL maintainer="InMon Corp. https://inmon.com"
LABEL description="Multi-architecture CONTAINERlab"
LABEL url=https://hub.docker.com/r/sflow/clab
COPY --from=build /containerlab/bin/containerlab /usr/bin/containerlab
COPY --from=build /containerlab/templates /etc/containerlab/templates
RUN apk add --no-cache bash curl docker-cli git openssh make iptables device-mapper e2fsprogs-extra python3
CMD ["/usr/bin/containerlab", "help"]
