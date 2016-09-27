# A simple scripted Kolla Launcher

As with any installation, there are certain pre-requisites that need to be 
in place.  For simple "devstack" like usage, we can pull from the Hub.docker.io
registry, and simply leverage/extend the default kolla driven ansible
inventory to manage deployment.

## Launch an "All-in-one" instance

This script sets up some prerequisites agains a CentOS based instance, then, using
the Kolla tools, launches a pull of the upstream (hub.docker) registered images. It
runs the ansible deploy script, and at the end it _should_ have a running baseline
OpenStack enviornment stood up.

This has been validated using machines from Packet.net (type_0).

## Add a compute node

A common operation is to extend a system with an additional compute node.  This 
requires launching an additional network and compute agent at a minimum, and configuring
those agents to communicate with the original all-in-one node.

Adding a node does require ssh communication from the all-in-one node to the compute
node being added to allow the ansible trigger to run.  This configuration requires 
adding at a minimum a public/private pair to the all-in-one node, and the public
key to the compute node to be added.  In addition, the centos-cmp.sh script should
be run on the compute node to establish the baseline resources needed for the system 
to support the dockerized resources for the kolla environment.

The create_ssh.sh script may assist in generating an authorized_keys file for use on 
the remote system.

## Network config

Because this was intended for setting up little test environments, the network config is 
fairly simplistic, including the scripted creation of a basic tenant/router/floating 
IP network.  The "public" services are associated with a linux bridge "external" bridge 
(br-ex), and an additional interface can readily be added if one is available for proper 
resource sharing.  In whcih case it woudl be sensible to look at the IP range set on the
bridge (which allows controller access to the "external" network), along with the
setup_network.sh script that configures the network and floating pool.
