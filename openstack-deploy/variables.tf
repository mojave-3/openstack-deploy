variable "project_id" {
  description = "ID of the GCP project"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-southeast1-b"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "openstack-network"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "openstack-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.10.0.0/24"
}
