# Launching Kolla based OpenStack

As with any installation, there are certain pre-requisites that need to be in place.  For simple "devstack" like usage, we can pull from the Hub.docker.io registry, and simply leverage/extend the default kolla driven ansible inventory to manage deployment.

## Quick Start

0) git clone this repository.
1) if you're going to use bare metal servers, install Ubuntu, and either add their IP addresses to DNS, or update the inventory with their IP addresses.
2) If you're going to use packet.net as your target, get an auth token from packet either via the packet API, or more commonly via the Packet.net web site.  Whlie you are at the site, get the packet Project ID as well.
2) update the project ID and auth token in the 'vars' section of the packet-ansible.yml
3) terraform plan
4) terraform apply
5) ansible-playbook -i inventory configure_baseline.yml

## Launch an "All-in-one" instance

This script sets up some prerequisites agains a CentOS or Ubuntu based instance, then, using the Kolla tools, launches a pull of the upstream (hub.docker) registered images. It runs the ansible deploy script, and at the end it _should_ have a running baseline OpenStack enviornment stood up.

This has been validated using machines from Packet.net (type_0).

To run this script, you can just pull the repository down via git (likely have to install git on the target), and then just run the centos.sh or ubuntu.sh

## Add a compute node

A common operation is to extend a system with an additional compute node.  This requires launching an additional network and compute agent at a minimum, and configuring those agents to communicate with the original all-in-one node.

Adding a node does require ssh communication from the all-in-one node to the compute node being added to allow the ansible trigger to run.  This configuration requires adding at a minimum a public/private pair to the all-in-one node, and the public key to the compute node to be added.  In addition, the centos-cmp.sh script should be run on the compute node to establish the baseline resources needed for the system to support the dockerized resources for the kolla environment.

The simplest way to execute the required setup is to use ansible, possibly from another machine, to launch the configure_baseline.yml play.  This relies on information in the _inventory_ file, that should be configured as appropriate for your node names.

There are two parts to the inventory, one is a name for a device, which should match the hostname for the machine in question, and the second is the ansible_ssh_host parameter, which can map to either the fqdn of the machine if DNS is configured, or to the IP address of the node instead.

If you set the FQDN (and as long as that is configured in DNS), you should add a domain parameter in the [all:vars] section of the inventory file.

Once these parameters are configured, and so long as you have two nodes available (one for control, one for compute), you should be able to get to a running system via:

'''
ansible-playbook -i inventory configure_baseline.yml
'''

### Note about node roles
There is a templated kolla multi-node inventory marked as multinode.tmpl, that will soon become a jinja template. But for now, it might be interesting to remove compute from the control nodes, as a type_0 on packet is often too slow for any meaningful operations.  Or you may want to run the controller as a type_1 in which case compute is quite appropriate.

## Network config

Because this was intended for setting up little test environments, the network config is fairly simplistic, including the scripted creation of a basic tenant/router/floating IP network.  The "public" services are associated with a linux bridge "external" bridge (br-ex), and an additional interface can readily be added if one is available for proper resource sharing.  In whcih case it woudl be sensible to look at the IP range set on the bridge (which allows controller access to the "external" network), along with the setup_network.sh script that configures the network and floating pool.
