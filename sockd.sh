#!/bin/bash
set -e
[ -f /etc/openvpn/up.sh ] && /etc/openvpn/up.sh "$@"
/usr/sbin/sockd -D
nohup badvpn-udpgw --listen-addr 127.0.0.1:7300