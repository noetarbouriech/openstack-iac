resource "openstack_lb_loadbalancer_v2" "talos_control_plane_lb" {
  name           = "talos-control-plane"
  vip_subnet_id  = openstack_networking_subnet_v2.talos-subnet.id
  admin_state_up = true
}

resource "openstack_lb_listener_v2" "control_plane_listener" {
  name            = "talos-control-plane-listener"
  protocol        = "TCP"
  protocol_port   = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.talos_control_plane_lb.id
}

resource "openstack_lb_pool_v2" "control_plane_pool" {
  name        = "talos-control-plane-pool"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.control_plane_listener.id
}

resource "openstack_lb_monitor_v2" "control_plane_healthmonitor" {
  pool_id     = openstack_lb_pool_v2.control_plane_pool.id
  delay       = 5
  timeout     = 10
  max_retries = 4
  type        = "TCP"
}

resource "openstack_networking_port_v2" "control_plane_ports" {
  count      = 3
  name       = "talos-control-plane-${count.index}"
  network_id = openstack_networking_network_v2.talos.id
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.talos-subnet.id
  }
}

resource "openstack_networking_floatingip_v2" "control_plane_fips" {
  count   = 3
  port_id = openstack_networking_port_v2.control_plane_ports[count.index].id
  pool    = "public"
}

resource "openstack_lb_member_v2" "control_plane_members" {
  count         = 3
  pool_id       = openstack_lb_pool_v2.control_plane_pool.id
  address       = openstack_networking_floatingip_v2.control_plane_fips[count.index].address
  protocol_port = 6443
  subnet_id     = openstack_networking_subnet_v2.talos-subnet.id
}

resource "openstack_networking_floatingip_v2" "loadbalancer_fip" {
  pool = "public"
}

resource "openstack_networking_floatingip_associate_v2" "loadbalancer_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.loadbalancer_fip.address
  port_id     = openstack_lb_loadbalancer_v2.talos_control_plane_lb.vip_port_id
}
