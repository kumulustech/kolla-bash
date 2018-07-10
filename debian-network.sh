#!/bin/bash

mkdir -p /etc/kolla/

if [[ $(ip l | grep team) ]]; then
NETWORK_INTERFACE="team0"
NEUTRON_INTERFACE="ext"
elif [[ $(ip l | grep bond) ]]; then
NETWORK_INTERFACE="bond0"
NEUTRON_INTERFACE="ext"
elif [[ $(ip l | grep enp0s8) ]]; then
NETWORK_INTERFACE="enp0s8"
NEUTRON_INTERFACE="ext"
ifup enp0s9
elif [[ $(ip l | grep eth0) ]]; then
NETWORK_INTERFACE="eth0"
NEUTRON_INTERFACE="eth0.2"
vlan-raw-device eth1
modprobe 8021q
vconfig add eth0 2

cat > /etc/network/interfaces.d/vlan2 <<EOF
auto eth0.2
iface eth0.2 inet manual
  vlan-raw-device eth0
EOF

cat > /etc/modprobe.d/vlan.conf <<EOF
8021q
EOF
else
echo "Can't figure out network interface, please manually edit"
exit 1
fi
NEUTRON_PUB="$(ip -4 addr show ${NEUTRON_INTERFACE} | grep "${NEUTRON_INTERFACE}" | head -1 |awk '{print $2}' | cut -d/ -f1)"
BASE="$(echo ${NEUTRON_PUB} | cut -d. -f 1,2,3)"

GLOBALS_FILE="/etc/kolla/globals.yml"
ADDRESS="$(ip -4 addr show ${NETWORK_INTERFACE} | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"

VIP="${ADDRESS}"
if [ ! -f /etc/kolla/globals.yml ]; then
cat >> ${GLOBALS_FILE} <<EOF
---
kolla_internal_vip_address: "${VIP}"
network_interface: "${NETWORK_INTERFACE}"
neutron_external_interface: "${NEUTRON_INTERFACE}"
enable_haproxy: "no"
#enable_central_logging: "yes"
kolla_base_distro: "ubuntu"
kolla_install_type: "source"
openstack_release: "queens"
#enable_ceph: "yes"
#enable_ceph_rgw: "yes"
#ceph_enable_cache: "yes"
#ceph_pool_type: "erasure"
#enable_ceph_rgw_keystone: "yes"
#glance_backend_ceph: "yes"
#gnocchi_backend_storage: "{{ 'ceph' if enable_ceph|bool else 'file' }}"
#enable_cinder: "yes"
#cinder_backend_ceph: "{{ enable_ceph }}"
#cinder_backup_driver: "swift"
#nova_backend_ceph: "{{ enable_ceph }}"
#external_journal: false
#ceph_erasure_profile: "k=3 m=1 ruleset-failure-domain=host"
#enable_trove: "yes"
#enable_horizon_trove: "{{ enable_trove | bool }}"
#docker_registry: "gitlab.kumulus.co:5000"
#docker_namespace: "kumulus/kolla"
#enable_cloudkitty: "yes"
#enable_designate: "yes"
#designate_backend: "bind9"
#designate_ns_record: "${VIP}"
enable_openvswitch: "no"
neutron_plugin_agent: "linuxbridge"
#cloudkitty_collector_backend: "gnocchi"
#enable_gnocchi: "yes"
enable_neutron_sfc: "yes"
enable_central_logging: "yes"
EOF
fi

if [ `egrep -c 'vmx|svm|0xc0f' /proc/cpuinfo` == '0' ] ;then
if [ ! -f /etc/kolla/config/nova/nova-compute.conf ]; then
mkdir -p /etc/kolla/config/nova/
tee > /etc/kolla/config/nova/nova-compute.conf <<-EOF
[libvirt]
virt_type=qemu
EOF
fi
else
if [ ! -f /etc/kolla/config/nova/nova-compute.conf ]; then
mkdir -p /etc/kolla/config/nova/
tee > /etc/kolla/config/nova/nova-compute.conf <<-EOF
[libvirt]
#cpu_mode=host-passthrough
cpu_mode = custom
cpu_model = SandyBridge
EOF
fi
fi

if [ -f /etc/kolla/passwords.yml ]; then
kolla-genpwd
sed -i "s/^keystone_admin_password:.*/keystone_admin_password: River123/" /etc/kolla/passwords.yml
fi

