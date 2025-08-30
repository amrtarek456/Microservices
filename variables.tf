variable "project_id" { type = string }
variable "region"     { type = string  default = "me-central2" }
variable "zone"       { type = string  default = "me-central2-a" }

variable "network_name" { type = string  default = "gke-vpc" }

variable "mgmt_subnet_name" { type = string  default = "mgmt-subnet" }
variable "mgmt_subnet_cidr" { type = string  default = "10.0.0.0/24" }

variable "gke_subnet_name" { type = string  default = "gke-private-subnet" }
variable "gke_subnet_cidr" { type = string  default = "10.10.0.0/16" }

variable "pods_secondary_cidr"     { type = string  default = "10.20.0.0/14" }
variable "services_secondary_cidr" { type = string  default = "10.50.0.0/20" }

variable "cluster_name" { type = string  default = "demo-gke-private" }
variable "machine_type" { type = string  default = "e2-small" }
variable "node_count"   { type = number  default = 1 }
variable "preemptible"  { type = bool    default = false }

variable "master_ipv4_cidr" { type = string default = "172.16.0.0/28" }

variable "bastion_name"         { type = string default = "gke-bastion" }
variable "bastion_machine_type" { type = string default = "e2-micro" }

variable "iap_members" {
  description = "List of principals to grant IAP + OS Login, e.g. ['user:you@example.com']"
  type        = list(string)
  default     = []
}

variable "oslogin_admin" {
  description = "Grant OS Admin Login (sudo) instead of OS Login (non-sudo)"
  type        = bool
  default     = true
}
