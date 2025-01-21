# Create a router and attach it to the public network
resource "openstack_networking_router_v2" "router" {
  name                = "my-router"
  admin_state_up      = true
  external_network_id = "fbef2fab-472b-4c35-8d1c-be6fa156b193"
}

# Create a private network
resource "openstack_networking_network_v2" "private_network" {
  name           = "my-private-network"
  admin_state_up = true
}

# Create a subnet in the private network
resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "my-private-subnet"
  network_id      = openstack_networking_network_v2.private_network.id
  cidr            = "192.168.0.0/24"
  ip_version      = 4
  dns_nameservers = ["9.9.9.9"]
}

# Attach the private network to the router
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}

# Internal security group
resource "openstack_networking_secgroup_v2" "internal_secgroup" {
  name = "internal-secgroup"
}

resource "openstack_networking_secgroup_rule_v2" "internal_tcp_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3000
  port_range_max    = 3000
  remote_ip_prefix  = "192.168.0.0/24" # Adjust as needed
  security_group_id = openstack_networking_secgroup_v2.internal_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal_tcp_udp_psql" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_ip_prefix  = "192.168.0.0/24" # Adjust as needed
  security_group_id = openstack_networking_secgroup_v2.internal_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.internal_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "192.168.0.0/24" # Adjust as needed
  security_group_id = openstack_networking_secgroup_v2.internal_secgroup.id
}

# External security group
resource "openstack_networking_secgroup_v2" "external_secgroup" {
  name = "external-secgroup"
}

resource "openstack_networking_secgroup_rule_v2" "external_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.external_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "external_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.external_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "external_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.external_secgroup.id
}
