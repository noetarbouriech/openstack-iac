# Fetch the Image
data "openstack_images_image_v2" "image" {
  name = var.image_name
}

# Fetch the Flavor
data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

# Create the VM
resource "openstack_compute_instance_v2" "vm" {
  name            = var.vm_name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.key_pair
  security_groups = [var.sg_name]

  network {
    name = var.network_name
  }

  metadata = {
    description = "Deployed via OpenTofu on OpenStack"
  }
}

# Create a Floating IP
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "public"
}

# Associate the Floating IP to the VM
resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.vm.id
}
