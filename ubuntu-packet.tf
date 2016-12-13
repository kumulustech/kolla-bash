# Create a multi-node openstack system in Packet.net

# The title of this project specifies packet, but in reaility
# it is packet.net and didigitalocean.com services that are
# used in order to enable dns resolution of names for nodes
# that are created

# Note: You will need to source a file that has the following two
# tokens defined:

# export PACKET_AUTH_TOKEN=GET_PACKET_AUTH_TOKEN_FROM_API_PAGES
# export TOKEN=GET_DIGITAL_OCEAN_TOKEN_FROM_API_PAGES
# export DIGITALOCEAN_TOKEN=${TOKEN}

# If you don't already have a domain defined in Digital Ocean,
# uncomment the next three lines tocreate one, and we'll
# use digital ocean as our DNS service

#variable domain_name {
#    type = "string"
#    default = "opsits.com"
#}

# resource "digitalocean_domain" "${var.domain_name}" {
#     name = "${var.domain_name}"
# }

# packet images:
# ubuntu_16_04_image
# ubuntu_14_04_image
# ubuntu_16_04_image
# curl -H "X-Auth-Token: ${PACKET_AUTH_TOKEN}" https://api.packet.net/operating-systems

# packet facilities:
# ewr1
# sjc1
# ams1

# plan:
# baremetal_0 average
# baremetal_1
# baremetal_2
# baremetal_4

resource "packet_device" "kolla-control" {
        hostname = "kolla-control"
        plan = "baremetal_1"
        facility = "ewr1"
        operating_system = "ubuntu_16_04_image"
        billing_cycle = "hourly"
        project_id = "320c2c2f-6876-4621-929a-93a47e07d2da"
        provisioner "local-exec" {
          command = "sed -i '' -e 's/kolla-control.*/kolla-control ansible_ssh_host=${packet_device.kolla-control.network.0.address}/' inventory"
        }
}


#resource "packet_device" "kolla-compute" {
#        hostname = "kolla-compute"
#        plan = "baremetal_1"
#        facility = "ewr1"
#        operating_system = "ubuntu_16_04_image"
#        billing_cycle = "hourly"
#        project_id = "320c2c2f-6876-4621-929a-93a47e07d2da"
#        provisioner "local-exec" {
#          command = "sed -i '' -e 's/kolla-compute.*/kolla-compute ansible_ssh_host=${packet_device.kolla-compute.network.0.address}/' inventory"
#        }
#}

###resource "packet_device" "kolla-registry" {
###        hostname = "kolla-registry"
###        plan = "baremetal_0"
###        facility = "ewr1"
###	operating_system = "ubuntu_16_04_image"
###        billing_cycle = "hourly"
###        project_id = "320c2c2f-6876-4621-929a-93a47e07d2da"
###}

# Add a pointer to the new IP address
# Note that the default TTYL is 1800 seconds, so it will take
# up to 30 minutes in this enviornment for the record to time out.

#resource "digitalocean_record" "kolla-control" {
#    domain = "${var.domain_name}"
#    type = "A"
#    name = "kolla-control"
#    value = "${packet_device.kolla-control.network.0.address}"
#}
#
###resource "digitalocean_record" "kolla-registry" {
###    domain = "${var.domain_name}"
###    type = "A"
###    name = "kolla-registry"
###    value = "${packet_device.kolla-registry.network.0.address}"
###}

#resource "digitalocean_record" "kolla-compute" {
#    domain = "${var.domain_name}"
#    type = "A"
#    name = "kolla-compute"
#    value = "${packet_device.kolla-compute.network.0.address}"
#}
