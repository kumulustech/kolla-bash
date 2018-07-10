#!/bin/bash
source ~/dev/packet.api
ansible-playbook -i localhost-inventory deploy-packet.yml -e project_id=${PACKET_PROJECT}
