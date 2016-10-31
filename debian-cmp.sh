#!/bin/bash

apt-get install bridge-utils -y


apt install python-pip -y
apt install \
    vim \
    htop \
    python-dev \
    python-netaddr \
    python-openstackclient \
    python-neutronclient \
    libffi-dev \
    libssl-dev \
    gcc \
    apt-transport-https \
    ca-certificates \
    bridge-utils -y

pip install ansible==2.1.2.0

apt-get install apt-transport-https ca-certificates -y
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
deb https://apt.dockerproject.org/repo ubuntu-xenial main
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install docker-engine -y

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
systemctl enable docker
systemctl restart docker

pip install ansible

if [[ $(ip l | grep team) ]]; then
NETWORK_INTERFACE="team0"
NEUTRON_INTERFACE="team0:0"
elif [[ $(ip l | grep bond) ]]; then
NETWORK_INTERFACE="bond0"
NEUTRON_INTERFACE="bond0:0"
elif [[ $(ip l | grep enp0s8) ]]; then
NETWORK_INTERFACE="enp0s8"
NEUTRON_INTERFACE="enp0s9"
ifup enp0s9
else
echo "Can't figure out network interface, please manually edit"
exit 1
fi
NEUTRON_PUB="$(ip -4 addr show ${NEUTRON_INTERFACE} | grep "${NEUTRON_INTERFACE}" | head -1 |awk '{print $2}' | cut -d/ -f1)"
BASE="$(echo ${NEUTRON_PUB} | cut -d. -f 1,2,3)"

ADDRESS="$(ip -4 addr show ${NETWORK_INTERFACE} | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"

sed -i "s/^127.0.1.1\(.*\)/${ADDRESS}\1/" /etc/hosts
if [[ -z $(grep ${ADDRESS} /etc/hosts) ]]; then
echo "${ADDRESS} $(hostname)" >> /etc/hosts
fi

if [ `egrep -c 'vmx|svm|0xc0f' /proc/cpuinfo` == '0' ] ;then
if [ ! -f /etc/kolla/config/nova/nova-compute.conf ]; then
mkdir -p /etc/kolla/config/nova/
tee > /etc/kolla/config/nova/nova-compute.conf <<-EOF
[libvirt]
virt_type=qemu
EOF
fi
fi

