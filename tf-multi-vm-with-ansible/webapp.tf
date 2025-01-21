# Create the First Web Application VM
resource "openstack_compute_instance_v2" "webapp1_vm" {
  name      = "webapp1_vm"
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
    ansible_host = "webapp1_vm"
  }
}

# Create a Floating IP
resource "openstack_networking_floatingip_v2" "webapp1_fip" {
  pool = "public"
}

# Associate the Floating IP to the VM
resource "openstack_compute_floatingip_associate_v2" "webapp1_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.webapp1_fip.address
  instance_id = openstack_compute_instance_v2.webapp1_vm.id
}

# Run the Ansible playbook for the VM after the floating IP is associated
resource "null_resource" "webapp1_provisioner" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 30  # Wait for 30 seconds
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u debian -i ${openstack_networking_floatingip_v2.webapp1_fip.address}, --private-key ~/.ssh/id_ed25519 -e database_ip=${openstack_compute_instance_v2.database_vm.access_ip_v4} playbooks/docker-svc.yml
    EOT
  }

  depends_on = [
    openstack_compute_instance_v2.webapp1_vm,
    openstack_compute_floatingip_associate_v2.webapp1_fip_assoc
  ]
}




# Create the Second Web Application VM
resource "openstack_compute_instance_v2" "webapp2_vm" {
  name      = "webapp2_vm"
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
    ansible_host = "webapp2_vm"
  }
}

# Create a Floating IP
resource "openstack_networking_floatingip_v2" "webapp2_fip" {
  pool = "public"
}

# Associate the Floating IP to the VM
resource "openstack_compute_floatingip_associate_v2" "webapp2_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.webapp2_fip.address
  instance_id = openstack_compute_instance_v2.webapp2_vm.id
}

# Run the Ansible playbook for the VM after the floating IP is associated
resource "null_resource" "webapp2_provisioner" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 30  # Wait for 30 seconds
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u debian -i ${openstack_networking_floatingip_v2.webapp2_fip.address}, --private-key ~/.ssh/id_ed25519 -e database_ip=${openstack_compute_instance_v2.database_vm.access_ip_v4} playbooks/docker-svc.yml
    EOT
  }

  depends_on = [
    openstack_compute_instance_v2.webapp2_vm,
    openstack_compute_floatingip_associate_v2.webapp2_fip_assoc
  ]
}
