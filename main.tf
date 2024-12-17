# Fetch the Image
data "openstack_images_image_v2" "image" {
  name = var.image_name
}

# Fetch the Flavor
data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}

# Fetch the Network
data "openstack_networking_network_v2" "network" {
  name = var.network_name
}

# Create the VM
resource "openstack_compute_instance_v2" "vm" {
  name            = var.vm_name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.key_pair
  security_groups = [var.sg_name]

  network {
    uuid = data.openstack_networking_network_v2.network.id
  }

  metadata = {
    description = "Deployed via OpenTofu on OpenStack"
  }
}
