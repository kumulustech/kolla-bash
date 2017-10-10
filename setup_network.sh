#!/bin/bash
#   Copyright 2016 Kumulus Technologies <info@kumul.us>
#   Copyright 2016 Robert Starmer <rstarmer@gmail.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.source ~/admin.rc

source ~/open.rc

tenant=`openstack project list -f csv --quote none --insecure | grep admin | cut -d, -f1`

public_network=${1:-53.255.81}
#ip a a ${public_network}.1/24 dev br-ex
#ip l s br-ex up

openstack network create public --project admin --external --provider-network-type flat --provider-physical-network physnet1 --share --default --insecure
#if segmented network{vlan,vxlan,gre}: --provider:segmentation_id ${segment_id}
openstack subnet create public --subnet-range ${public_network}.0/24 --project admin --gateway 53.255.81.254 --allocation-pool start=${public_network}.50,end=${public_network}.250 --no-dhcp --network public --insecure
# if you need a specific route to get "out" of your public network: --host-route destination=10.0.0.0/8,nexthop=10.1.10.254

openstack  network create private --project admin --insecure
openstack  subnet create private --subnet-range 192.168.100.0/24 --project admin --dns-nameserver 53.255.82.245 --dns-nameserver 53.255.64.245 --dhcp --network private --insecure


openstack  router create pub-router --project admin --ha --insecure

openstack  router set pub-router --external-gateway public --insecure
openstack  router add subnet pub-router private --insecure

# Adjust the default security group.  This is not good practice
default_group=`openstack  security group list --project admin --insecure | awk '/ default / {print $2}'`
openstack  security group rule create --ingress --dst-port 22 --protocol tcp --remote-ip 0.0.0.0/0 ${default_group}  --insecure
openstack  security group rule create --ingress --dst-port 80 --protocol tcp --remote-ip 0.0.0.0/0 ${default_group}  --insecure
openstack  security group rule create --ingress --dst-port 443 --protocol tcp --remote-ip 0.0.0.0/0 ${default_group}  --insecure
openstack  security group rule create --ingress --protocol icmp --remote-ip 0.0.0.0/0 ${default_group}  --insecure
