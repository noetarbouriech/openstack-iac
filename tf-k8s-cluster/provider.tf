terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
  }
}

provider "talos" {}

provider "openstack" {
  auth_url    = var.auth_url
  tenant_name = var.tenant_name
  user_name   = var.user_name
  password    = var.password
  region      = var.region
  insecure    = true
}
