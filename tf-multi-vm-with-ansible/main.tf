# Fetch the Image
data "openstack_images_image_v2" "image" {
  name = var.image_name
}

# Fetch the Flavor
data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}
