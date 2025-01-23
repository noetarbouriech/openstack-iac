# Create the VM
resource "openstack_compute_instance_v2" "database_vm" {
  name      = "database_vm"
  image_id  = data.openstack_images_image_v2.image.id
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  key_pair  = var.key_pair
  security_groups = [
    openstack_networking_secgroup_v2.internal_secgroup.name,
    openstack_networking_secgroup_v2.external_secgroup.name
  ]

  network {
    uuid = openstack_networking_network_v2.private_network.id
  }

  metadata = {
    description  = "Deployed via OpenTofu on OpenStack"
    ansible_host = "database"
  }
}

# Run the Ansible playbook for the VM after the floating IP is associated
resource "null_resource" "database_provisioner" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 30  # Wait for 30 seconds
      
      # Disable host key checking and run the playbook
      ANSIBLE_HOST_KEY_CHECKING=False \
      ANSIBLE_SSH_ARGS='-o ProxyCommand="ssh -o "StrictHostKeyChecking=no" -o UserKnownHostsFile=/dev/null -W %h:%p -q debian@${openstack_networking_floatingip_v2.loadbalancer_fip.address}" -o "StrictHostKeyChecking=no" -o UserKnownHostsFile=/dev/null' \
      ansible-playbook \
        -u debian \
        -i ${openstack_compute_instance_v2.database_vm.access_ip_v4}, \
        --private-key ~/.ssh/id_ed25519 \
        -e webapp1_ip=${openstack_compute_instance_v2.webapp1_vm.access_ip_v4} \
        -e webapp2_ip=${openstack_compute_instance_v2.webapp2_vm.access_ip_v4} \
        playbooks/postgresql.yml
    EOT
  }

  depends_on = [
    openstack_compute_instance_v2.database_vm,
    openstack_compute_floatingip_associate_v2.loadbalancer_fip_assoc
  ]
}
