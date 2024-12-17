output "vm_id" {
  description = "The ID of the created VM"
  value       = openstack_compute_instance_v2.vm.id
}

output "vm_access_ip" {
  description = "The access IP of the VM"
  value       = openstack_compute_instance_v2.vm.access_ip_v4
}
