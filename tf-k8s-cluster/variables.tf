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
