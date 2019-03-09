
locals {
  # Point the key variables at the ssh key you want to use for
  # accessing your instances.

  # the private component is referenced when calling ansible
  privkey = "~/.ssh/id_rsa"
  # the public component is passed to the hetzner ssh key resource
  pubkey = "${file("~/.ssh/id_rsa.pub")}"
  # the Hetzner location where the servers are provisioned - Helsinki in this case
  location = "hel1" 
  # the number of nodes to create
  node_count = "2"
}

# you don't need to configure anything else in this file

variable "TOKEN" {
  description = "Hetner cloud project API token"
}

output "Master" {
  value = "${hcloud_server.master.ipv4_address}"
}

output "Nodes" {
  value = "${hcloud_server.node.*.ipv4_address}"
}

resource "hcloud_ssh_key" "ssh_key" {
  name = "k8s"
  public_key = "${local.pubkey}"
}

provider "hcloud" {
  token = "${var.TOKEN}"
}

resource "hcloud_server" "master" {
  name = "master"
  image = "centos-7"
  server_type = "cx21"
  location = "hel1"
  ssh_keys = ["${hcloud_ssh_key.ssh_key.name}"]
}

resource "hcloud_server" "node" {
  count = "${local.node_count}"
  name = "node${count.index + 1}"
  image = "centos-7"
  server_type = "cx21"
  location = "hel1"
  ssh_keys = ["${hcloud_ssh_key.ssh_key.name}"]
}

resource "null_resource" "cluster" {
  depends_on = ["hcloud_server.master", "hcloud_server.node"]
  provisioner "local-exec" {
    command = <<EOF
    while ! nc -z ${hcloud_server.master.ipv4_address} 22;
    do
    sleep 1;
    done;
    sleep 10;
    ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook \
        -e master_ip=${hcloud_server.master.ipv4_address} \
        -u root \
        --private-key "${local.privkey}" \
        -i '${hcloud_server.master.ipv4_address},${join(",", hcloud_server.node.*.ipv4_address)}' \
        kubernetes.yml
    EOF
  }
}
