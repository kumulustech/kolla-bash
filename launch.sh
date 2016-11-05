#!/bin/bash

. ~/open.rc

nova boot --flavor 3 --image cirros --nic net-id=`neutron net-list | awk '/ private / {print $2}'` test
floating_ip=`neutron floatingip-create public | awk '/ floating_ip_address / {print $4}'`
nova floating-ip-associate test ${floating_ip}


