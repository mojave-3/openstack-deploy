provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Lấy image Ubuntu 22.04 mới nhất
data "google_compute_image" "ubuntu2204" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# VPC riêng
resource "google_compute_network" "openstack" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "openstack_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.openstack.id
}

# Firewall cho SSH + HTTP/HTTPS
resource "google_compute_firewall" "ssh_http" {
  name    = "${var.network_name}-allow-ssh-http"
  network = google_compute_network.openstack.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall cho nội bộ
resource "google_compute_firewall" "internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.openstack.id

  allow {
    protocol = "tcp"
