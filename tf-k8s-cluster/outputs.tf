output "loadbalancer_ip" {
  description = "The IP of the created load balancer"
  value       = openstack_networking_floatingip_v2.loadbalancer_fip.address
}
