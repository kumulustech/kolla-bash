#!/bin/bash

yum install bridge-utils -y

cat > /etc/sysconfig/network-scripts/ifcfg-br1 <<EOF
DEVICE=br1
TYPE=Bridge
IPADDR=192.168.10.10
NETMASK=255.255.255.0
ONBOOT=yes
BOOTMODE=static
EOF

ifup br1

setenforce 0
sed -i "s/^\s*SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config

yum -y install epel-release centos-release-openstack-mitaka

yum -y install \
    lvm2 \
    vim \
    net-tools \
    python-pip \
    python-devel \
    python-docker-py \
    python-openstackclient \
    python-neutronclient \
    libffi-devel \
    openssl-devel \
    gcc \
    make \
    ntp \
    docker

pip install -U pip

mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf <<-EOF
[Service]
MountFlags=shared
EOF

systemctl daemon-reload
systemctl enable docker
systemctl enable ntpd.service
systemctl restart docker
systemctl restart ntpd.service

systemctl stop libvirtd.service
systemctl disable libvirtd.service

pip install ansible==1.9.6

NETWORK_INTERFACE="team0"
NEUTRON_INTERFACE="br1"
GLOBALS_FILE="/etc/kolla/globals.yml"
ADDRESS="$(ip -4 addr show ${NETWORK_INTERFACE} | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
BASE="$(echo ${ADDRESS} | cut -d. -f 1,2,3)"
#VIP=$(echo "${BASE}.254")
VIP="${ADDRESS}"

echo "${ADDRESS} $(hostname)" >> /etc/hosts

