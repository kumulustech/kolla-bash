#!/bin/bash
source ~/dev/packet.api
ansible-playbook -i localhost-inventory deploy-packet.yml -e packet_id=${PACKET_PROJECT} -e dnsimple_token=${DNSIMPLE_TOKEN} -e dnsimple_account=${DNSIMPLE_ACCOUNT} -e build=absent
