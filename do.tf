# Create a Virtual Machine

# One can provide the Digital Ocean access token via numerous methods
# including passing a variable (from another file, a file passed from the CLI)
# or as an environment variable: export DIGITALOCEAN_TOKEN='xxxx'
# provider "digitalocean" {
#     token = "${var.do_token}"
# }

# images:
#  - ubuntu-15-10-x64
#  - ubuntu-14-04-x64
#  - centos-7-0-x64
#  - coreos-beta
#  Provision via external ansible, but create the inventory
resource "digitalocean_volume" "ceph-a" {
  region      = "sfo2"
  name        = "ceph-a-${count.index}"
  count       = 3
  size        = 100
  description = "ceph volume"
}
resource "digitalocean_volume" "ceph-b" {
  region      = "sfo2"
  name        = "ceph-b-${count.index}"
  count       = 3
  size        = 100
  description = "ceph journal volume"
}
resource "digitalocean_volume" "ceph-c" {
  region      = "sfo2"
  name        = "ceph-c-${count.index}"
  count       = 3
  size        = 100
  description = "ceph cache volume"
}

resource "digitalocean_volume" "ceph-d" {
  region      = "sfo2"
  name        = "ceph-d-${count.index}"
  count       = 3
  size        = 100
  description = "ceph cache volume"
}
resource "digitalocean_volume" "ceph-e" {
  region      = "sfo2"
  name        = "ceph-e-${count.index}"
  count       = 3
  size        = 100
  description = "ceph cache volume"
}
resource "digitalocean_volume" "ceph-f" {
  region      = "sfo2"
  name        = "ceph-f-${count.index}"
  count       = 3
  size        = 100
  description = "ceph cache volume"
}
resource "digitalocean_volume" "ceph-g" {
  region      = "sfo2"
  name        = "ceph-g-${count.index}"
  count       = 3
  size        = 100
  description = "ceph cache volume"
}

resource "digitalocean_droplet" "kolla" {
    image = "ubuntu-16-04-x64"
    name = "rhs-kolla-${count.index}"
    region = "sfo2"
    size = "8gb"
    ssh_keys = ["778729"]
    count = 3
    volume_ids = ["${element(digitalocean_volume.ceph-a.*.id,count.index)}","${element(digitalocean_volume.ceph-b.*.id,count.index)}","${element(digitalocean_volume.ceph-c.*.id,count.index)}","${element(digitalocean_volume.ceph-d.*.id,count.index)}","${element(digitalocean_volume.ceph-e.*.id,count.index)}","${element(digitalocean_volume.ceph-f.*.id,count.index)}","${element(digitalocean_volume.ceph-g.*.id,count.index)}"]
##    provisioner "remote-exec" {
##      inline = [
##        "sudo apt-get update && sudo apt-get -y install python-minimal",
##      ]
##  
##      connection {
##        type     = "ssh"
##        private_key = "${file("~/.ssh/id_rsa")}"
##        user     = "root"
##        timeout  = "2m"
##      } 
##    }
    provisioner "local-exec" {
      command = "echo rhs-kolla-${count.index} ansible_ssh_host=kolla-${count.index}.opsits.com ansible_connection=ssh ansible_ssh_user=root >> inventory"
    }
}
resource "digitalocean_record" "kolla" {
    domain = "opsits.com"
    type = "A"
    count = 3
    name = "rhs-kolla-${count.index}"
    value = "${element(digitalocean_droplet.kolla.*.ipv4_address,count.index)}"
}
