resource "openstack_images_image_v2" "talos_image" {
  name             = "talos"
  hidden           = true
  visibility       = "private"
  disk_format      = "raw"
  container_format = "bare"
  local_file_path  = "talos/disk.raw"
}

resource "openstack_compute_instance_v2" "control_planes" {
  count       = 3
  name        = "talos-control-plane-${count.index}"
  flavor_name = "m1.medium"
  network {
    port = openstack_networking_port_v2.control_plane_ports[count.index].id
  }
  block_device {
    uuid                  = openstack_images_image_v2.talos_image.id
    source_type           = "image"
    volume_size           = 50
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  user_data       = base64encode(data.talos_machine_configuration.control_plane.machine_configuration)
  security_groups = [openstack_networking_secgroup_v2.talos-controlplane.name]
}

resource "openstack_compute_instance_v2" "worker_nodes" {
  count       = 1
  name        = "talos-worker-${count.index}"
  flavor_name = "m1.medium"
  network {
    name = openstack_networking_network_v2.talos.name
  }
  block_device {
    uuid                  = openstack_images_image_v2.talos_image.id
    source_type           = "image"
    volume_size           = 50
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  user_data       = base64encode(data.talos_machine_configuration.worker_node.machine_configuration)
  security_groups = [openstack_networking_secgroup_v2.talos-controlplane.name]
}
