resource "talos_machine_secrets" "cluster" {}

data "talos_machine_configuration" "control_plane" {
  cluster_name     = "talos-cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://${openstack_networking_floatingip_v2.control_plane_fips.0.address}:6443"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
          wipe = true
        }
        certSANs = concat(
          openstack_networking_floatingip_v2.control_plane_fips[*].address,
          [openstack_networking_floatingip_v2.loadbalancer_fip.address]
        )

      }
    })
  ]
}

data "talos_machine_configuration" "worker_node" {
  cluster_name     = "talos-cluster"
  machine_type     = "worker"
  cluster_endpoint = "https://${openstack_networking_floatingip_v2.control_plane_fips.0.address}:6443"
  machine_secrets  = talos_machine_secrets.cluster.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
          wipe = true
        }
      }
    })
  ]
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = "talos-cluster"
  client_configuration = talos_machine_secrets.cluster.client_configuration
  endpoints            = openstack_networking_floatingip_v2.control_plane_fips.*.address
  nodes                = [openstack_networking_floatingip_v2.control_plane_fips.0.address]
}

resource "local_file" "talos_config" {
  content  = data.talos_client_configuration.talosconfig.talos_config
  filename = "talos/talosconfig"
}

resource "talos_machine_bootstrap" "cluster" {
  node                 = openstack_compute_instance_v2.control_planes.0.network.0.fixed_ip_v4
  endpoint             = openstack_networking_floatingip_v2.control_plane_fips.0.address
  client_configuration = talos_machine_secrets.cluster.client_configuration
}
