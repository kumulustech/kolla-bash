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

pip install ansible

git clone https://github.com/openstack/kolla
pip install kolla/

cp -r /usr/local/share/kolla/etc_examples/kolla /etc/

NETWORK_INTERFACE="bond0"
NEUTRON_INTERFACE="br-ex"
GLOBALS_FILE="/etc/kolla/globals.yml"
ADDRESS="$(ip -4 addr show ${NETWORK_INTERFACE} | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
BASE="$(echo ${ADDRESS} | cut -d. -f 1,2,3)"
#VIP=$(echo "${BASE}.254")
VIP="${ADDRESS}"

sed -i "s/^kolla_internal_vip_address:.*/kolla_internal_vip_address: \"${VIP}\"/g" ${GLOBALS_FILE}
sed -i "s/^#network_interface:.*/network_interface: \"${NETWORK_INTERFACE}\"/g" ${GLOBALS_FILE}

if [[ -z $(grep neutron_bridge_name ${GLOBALS_FILE}) ]]; then
cat >> ${GLOBALS_FILE} <<EOF
neutron_bridge_name: "br-ex"
enable_haproxy: "no"
enable_keepalived: "no"
enable_ceilometer: "yes"
enable_mongodb: "yes"
EOF
fi

sed -i "s/^#neutron_external_interface:.*/neutron_external_interface: \"${NEUTRON_INTERFACE}\"/g" ${GLOBALS_FILE}
sed -i "s/^${ADDRESS}.*/${ADDRESS} $(hostname)/" /etc/hosts
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

kolla-genpwd
sed -i "s/^keystone_admin_password:.*/keystone_admin_password: admin1/" /etc/kolla/passwords.yml
kolla-ansible prechecks
if [ ! $? == 0 ]; then
  echo prechecks failed
  exit 1
fi

kolla-ansible pull
if [ ! $? == 0 ]; then
  echo prechecks failed
  echo your system may not work
fi

kolla-ansible deploy
if [ ! $? == 0 ]; then
  echo prechecks failed
  exit 1
fi

tee > /root/open.rc <<EOF
#!/bin/bash

# set environment variables for Starmer's OpenStack demo install

# "source this file, don't subshell" predicate inspired by
# http://stackoverflow.com/a/23009039/6195005

if [[ $_ == $0 ]] ; then
    echo "You ran this script instead of sourcing it."
    echo "  usage: source $0"
    echo "Aborting."
    exit 1
else
    echo "Setting environment variables in the current shell"
fi

export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$(cat /etc/kolla/passwords.yml | grep "keystone_admin_password" | awk '{print $2}')
export OS_AUTH_URL=http://${ADDRESS}:35357/v3
export OS_IDENTITY_API_VERSION=3
EOF

bash ./import_image.sh

bash ./setup_network.sh

echo "Login using http://${ADDRESS} with default as domain,  admin as username, and $(cat /etc/kolla/passwords.yml | grep "keystone_admin_password" | awk '{print $2}') as password"
