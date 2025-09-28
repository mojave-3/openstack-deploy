provider "google" {
  project = var.project_id
  region  = "asia-southeast1"
  zone    = "asia-southeast1-b"
}

terraform {
  backend "gcs" {
    bucket = "photo-blog-466210-tfstate"
    prefix = "openstack"
  }
}

# Network
resource "google_compute_network" "openstack" {
  name                    = "openstack-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "openstack_subnet" {
  name          = "openstack-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-southeast1"
  network       = google_compute_network.openstack.id
}

# Firewall: SSH + ICMP + HTTP + OpenStack API
resource "google_compute_firewall" "openstack_fw" {
  name    = "openstack-firewall"
  network = google_compute_network.openstack.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "5000", "8774", "9292", "9696"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Controller Node
resource "google_compute_instance" "controller" {
  name         = "openstack-controller"
  machine_type = "e2-medium"
  zone         = "asia-southeast1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.openstack_subnet.name
    access_config {}
  }

  tags = ["openstack", "controller"]
}

# Compute Node
resource "google_compute_instance" "compute1" {
  name         = "openstack-compute-1"
  machine_type = "e2-medium"
  zone         = "asia-southeast1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.openstack_subnet.name
    access_config {}
  }

  tags = ["openstack", "compute"]
}
# Storage Node (Cinder)
resource "google_compute_instance" "storage1" {
  name         = "openstack-storage-1"
  machine_type = "e2-medium"
  zone         = "asia-southeast1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Extra disk for Cinder
  attached_disk {
    source      = google_compute_disk.cinder_disk.id
    device_name = "cinder-disk"
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.openstack_subnet.name
    access_config {}
  }

  tags = ["openstack", "storage"]
}

# Extra persistent disk for Cinder
resource "google_compute_disk" "cinder_disk" {
  name  = "cinder-disk"
  type  = "pd-standard"
  zone  = "asia-southeast1-b"
  size  = 50 # GB
}
