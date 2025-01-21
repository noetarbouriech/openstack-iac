# Provider Variables
variable "auth_url" {
  description = "The OpenStack authentication URL"
  type        = string
}

variable "tenant_name" {
  description = "The OpenStack tenant/project name"
  type        = string
}

variable "user_name" {
  description = "The OpenStack user name"
  type        = string
}

variable "password" {
  description = "The OpenStack password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The OpenStack region"
  type        = string
}

# VM Variables
variable "image_name" {
  description = "The OpenStack image name to use for the VM"
  type        = string
}

variable "flavor_name" {
  description = "The OpenStack flavor for the VM size"
  type        = string
}

variable "network_name" {
  description = "The OpenStack network to attach the VM"
  type        = string
}

variable "sg_name" {
  description = "The OpenStack security group to attach the VM"
  type        = string
}

variable "key_pair" {
  description = "The name of the SSH key pair to use"
  type        = string
}
