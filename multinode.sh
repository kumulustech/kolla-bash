#!/bin/bash

if [ $# -le "2" ] ; then
 echo "Usage: $0 control_ip_or_hostname compute_ip_or_hostname"
 exit 1
fi

if [ ! -f ~/.ssh/id_rsa ] ; then

fi
cat multinode.tmpl | sed -i 's/#__CONTROL__/${1}/' >/tmp/multinode_cmp.tmpl
cat /tmp/multinode_cmp.tmpl | sed =i 's/#__COMPUTE__/${2}\n##_COMPUTE__/' > multinode
rm /tmp/multinode_cmp.tmpl

echo "Run: kolla-ansible -i multinode deploy

