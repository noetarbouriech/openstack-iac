resource "openstack_networking_router_v2" "talos-router" {
  name                = "talos-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.public.id
}

resource "openstack_networking_network_v2" "talos" {
  name           = "talos-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "talos-subnet" {
  name            = "talos-subnet"
  network_id      = openstack_networking_network_v2.talos.id
  cidr            = "192.168.0.0/24"
  ip_version      = 4
  dns_nameservers = ["9.9.9.9"]
}

resource "openstack_networking_router_interface_v2" "talos-router-interface" {
  router_id = openstack_networking_router_v2.talos-router.id
  subnet_id = openstack_networking_subnet_v2.talos-subnet.id
}

resource "openstack_networking_secgroup_v2" "talos-controlplane" {
  name        = "talos"
  description = "Security group for Talos control plane"
}

resource "openstack_networking_secgroup_rule_v2" "k8s-api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  security_group_id = openstack_networking_secgroup_v2.talos-controlplane.id
}

resource "openstack_networking_secgroup_rule_v2" "talos-api-controlplane" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50000
  port_range_max    = 50000
  security_group_id = openstack_networking_secgroup_v2.talos-controlplane.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.talos-controlplane.id
}

resource "openstack_networking_secgroup_rule_v2" "internal_traffic" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "192.168.0.0/24"
  security_group_id = openstack_networking_secgroup_v2.talos-controlplane.id
}
