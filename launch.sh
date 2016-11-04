#!/bin/bash

nova boot --flavor 3 --image cirros --nic net-id=`neutron net-list | awk '/ private / {print $2}'` test
floating_ip=`neutron floatingip-create public | awk '/ floating-ip-address / {print $4}'`
nova floatingip-associate test ${floating_ip}


