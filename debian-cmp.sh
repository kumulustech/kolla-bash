#!/bin/bash

apt-get install bridge-utils -y

brctl addbr br-ex

if [[ -z $(grep br-ex /etc/network/interfaces) ]]; then
cat >> /etc/network/interfaces <<EOF
auto br-ex
iface br-ex inet static
  address 192.168.254.1
  netmask 255.255.255.0
EOF
fi
ifup br-ex

apt install python-pip -y
apt install \
    vim \
    python-dev \
    python-netaddr \
    python-openstackclient \
    python-neutronclient \
    libffi-dev \
    libssl-dev \
    gcc \
    ansible \
    bridge-utils \
    docker.io -y

apt-get purge lxc lxd -y
pip install -U pip
mkdir -p /etc/systemd/system/docker.service.d
if [[ -z $(grep shared /etc/systemd/system/docker.service.d/kolla.conf) ]]; then
tee /etc/systemd/system/docker.service.d/kolla.conf <<-EOF
[Service]
MountFlags=shared
EOF
fi

systemctl daemon-reload
systemctl enable dockerd
systemctl restart dockerd

NETWORK_INTERFACE="bond0"
NEUTRON_INTERFACE="br-ex"
ADDRESS="$(ip -4 addr show ${NETWORK_INTERFACE} | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"

sed -i "s/^${ADDRESS}.*/${ADDRESS} $(hostname)/" /etc/hosts
if [[ -z $(grep ${ADDRESS} /etc/hosts) ]]; then
echo "${ADDRESS} $(hostname)" >> /etc/hosts
fi
