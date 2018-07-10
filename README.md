# Launching Kolla based OpenStack

As with any installation, there are certain pre-requisites that need to be in place.  For simple "devstack" like usage, we can pull from the Hub.docker.io registry, and simply leverage/extend the default kolla driven ansible inventory to manage deployment.

## Quick Start

0) git clone this repository and select the ktos-050 branch
1) if you're going to use bare metal servers, install Ubuntu, and either add their IP addresses to DNS, or update the inventory with their IP addresses.
2) If you're going to use packet.net as your target, get an auth token from packet either via the packet API, or more commonly via the Packet.net web site.  Whlie you are at the site, get the packet Project ID as well.
2) update the project ID and auth token in the 'vars' section of the deploy-packet.yml
3) verify the python virtual environment path in localinventory
4) source the virtual environment activate script:

     . ~/.pyenv/kolla/bin/active
     # or create and activate:
     virtualenv ~/.pyenv/kolla; . ~/.pyenv/kolla/bin/active

4) Install the python components needed:

    pip install -r requirements.txt

5) Modify the deploy-packet.yml if you don't have a dnsimple domain

    ansible-playbook -i localinventory deploy-packet.yml

6) Update dns or change to IP based node names in "inventory"
7) review the settings in the globals.yml (in debian-network.sh) and deploy

    ansible-playbook -i inventory initialize.yml

## Launch an "All-in-one" instance

This script sets up some prerequisites agains a CentOS or Ubuntu based instance, then, using the Kolla tools, launches a pull of the upstream (hub.docker) registered images. It runs the ansible deploy script, and at the end it _should_ have a running baseline OpenStack environment stood up.

This has been validated using machines from Packet.net (type_0).

To run this script, you can just pull the repository down via git (likely have to install git on the target) and then make the necessary local modifications for your enviornment (specifically tokens and virtualenv path).

## Add a compute node

A common operation is to extend a system with an additional compute node.  This requires launching an additional network and compute agent at a minimum, and configuring those agents to communicate with the original all-in-one node.

Adding a node does require ssh communication from the all-in-one node to the compute node being added to allow the ansible trigger to run.  This configuration requires adding at a minimum a public/private pair to the all-in-one node, and the public key to the compute node to be added.

The simplest way to execute the required setup is to use ansible, possibly from another machine, to launch the initialize.yml play.  This relies on information in the _inventory_ file, that should be configured as appropriate for your node names.

There are two parts to the inventory, one is a name for a device, which should match the hostname for the machine in question, and the second is the ansible_ssh_host parameter, which can map to either the fqdn of the machine if DNS is configured, or to the IP address of the node instead.

If you set the FQDN (and as long as that is configured in DNS), you should add a domain parameter in the [all:vars] section of the inventory file.

Once these parameters are configured, and so long as you have two nodes available (one for control, one for compute), you should be able to get to a running system via:

'''
ansible-playbook -i inventory initialize.yml
'''

### Note about node roles
There is a templated kolla multi-node inventory that is generated from multinode.tmpl based on the inventory file. One change that might be useful would be to remove the "control" nodes from the compute target,, as a type_0 on packet is often too slow for any meaningful compute cooperation. You would want to update the initial deploy script to call out a different type of resource for the compute nodes in that case.

## Network config

Because this was intended for setting up little test environments, the network config is fairly simplistic, including the scripted creation of a basic tenant/router/floating IP network.  The "public" services are associated with a linux bridge "external" bridge (br-ex), and an additional interface can readily be added if one is available for proper resource sharing.  In which case it would be sensible to look at the IP range set on the bridge (which allows controller access to the "external" network), along with the setup_network.sh script that configures the network and floating pool.
