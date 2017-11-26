# OpenVPN client + SOCKS proxy
# Usage:
# Create configuration (.ovpn), mount it in a volume
# docker run --volume=something.ovpn:/ovpn.conf:ro --device=/dev/net/tun --cap-add=NET_ADMIN
# Connect to (container):1080
# Note that the config must have embedded certs
# See `start` in same repo for more ideas

FROM alpine

ADD sockd.sh /usr/local/bin/

RUN true \
    && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --update-cache dante-server openvpn bash openresolv openrc \
    && rm -rf /var/cache/apk/* \
    && chmod a+x /usr/local/bin/sockd.sh \
    && true

ADD sockd.conf /etc/

RUN cd / && apk add --update-cache git cmake make gcc build-base \
    && git clone https://github.com/ambrop72/badvpn.git && cd badvpn \
    && mkdir badvpn-build && cd badvpn-build \
    && cmake /badvpn/ -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 \
    && make && make install \
    && cd / && rm -rf /badvpn \
    && apk del --update-cache git cmake make gcc build-base

ENTRYPOINT [ \
    "/bin/bash", "-c", \
    "cd /etc/openvpn && /usr/sbin/openvpn --config *.conf --up /usr/local/bin/sockd.sh" \
    ]
