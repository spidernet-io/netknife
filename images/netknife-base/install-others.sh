#!/bin/bash

# Copyright 2017-2020 Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

packages=(
  # Additional iproute2 runtime dependencies
  libelf1
  libmnl0
  bash-completion
  iptables
  # ss
  iproute2
  # netstat
  net-tools
  arping
  iftop
  conntrack
  ipvsadm
  lsof
  iputils-ping
  iputils-tracepath
  tcpdump
  telnet
  # ssh / ssh-client
  curl
  netcat
  socat
  # nping
  nmap
  ssmping
  ethtool
  jq
  stress-ng
  # too big
  #sysstat
  pciutils
  iperf3
  netperf
  dnsutils
  dnsperf
)


export DEBIAN_FRONTEND=noninteractive
apt-get update
ln -fs /usr/share/zoneinfo/UTC /etc/localtime
apt-get install -y --no-install-recommends "${packages[@]}"
apt-get purge --auto-remove
apt-get clean
rm -rf /var/lib/apt/lists/*



#========= verify

iptables-legacy --version
iptables-nft --version
ip6tables-legacy --version
ip6tables-nft --version
ss -v
tc -V
netstat --version
arping -h
iftop  -h &>/dev/null
conntrack --version
# Can't initialize ipvs: Permission denied (you must be root)
which ipvsadm >/dev/null
which telnet >/dev/null
which nc >/dev/null
lsof -h >/dev/null
ping -V
ping6 -V
tracepath -V
tcpdump --version
curl -V
socat -V
nping -V
nmap -V
ssmping -v
ethtool --version
jq -V
stress-ng -V
lspci --version
iperf3 -v
netperf -V
#
#echo 'ENABLED="true"' > /etc/default/sysstat
#service sysstat restart
#sar -V
#
dig -v
dnsperf -h


exit 0


