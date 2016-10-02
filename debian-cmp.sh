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
    bridge-utils \
    docker.io -y

apt-get purge lxc lxd -y
pip install -U pip

apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
deb https://apt.dockerproject.org/repo ubuntu-xenial main
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install docker-engine -y

mkdir -p /etc/systemd/system/docker.service.d
if [[ -z $(grep shared /etc/systemd/system/docker.service.d/kolla.conf) ]]; then
tee /etc/systemd/system/docker.service.d/kolla.conf <<-EOF
[Service]
MountFlags=shared
EOF
fi

systemctl daemon-reload
systemctl enable docker
systemctl restart docker

if [[ $(ip l | grep team) ]]; then
NETWORK_INTERFACE="team0"
elif [[ $(ip l | grep bond) ]]; then
NETWORK_INTERFACE="bond0"
elif [[ $(ip l | grep enp0s8) ]]; then
NETWORK_INTERFACE="enp0s8"
else
echo "Can't figure out network interface, please manually edit"
exit 1
fi

NEUTRON_INTERFACE="br-ex"
ADDRESS="$(ip -4 addr show ${NETWORK_INTERFACE} | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"

sed -i "s/^${ADDRESS}.*/${ADDRESS} $(hostname)/" /etc/hosts
if [[ -z $(grep ${ADDRESS} /etc/hosts) ]]; then
echo "${ADDRESS} $(hostname)" >> /etc/hosts
fi
