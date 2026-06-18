# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
# Private subnets for GKE cluster and other private resources
resource "google_compute_subnetwork" "private_zone1" {
  name                     = "private-${local.zone1}"
  ip_cidr_range            = var.subnet_cidr_blocks.private_zone1
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.cluster_name}-pods"
    ip_cidr_range = var.gke_secondary_ranges.pods
  }

  secondary_ip_range {
    range_name    = "${var.cluster_name}-services"
    ip_cidr_range = var.gke_secondary_ranges.services
  }
}

resource "google_compute_subnetwork" "private_zone2" {
  name                     = "private-${local.zone2}"
  ip_cidr_range            = var.subnet_cidr_blocks.private_zone2
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true
}

# Public subnets for load balancers and other public facing resources
resource "google_compute_subnetwork" "public_zone1" {
  name                     = "public-${local.zone1}"
  ip_cidr_range            = var.subnet_cidr_blocks.public_zone1
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "public_zone2" {
  name                     = "public-${local.zone2}"
  ip_cidr_range            = var.subnet_cidr_blocks.public_zone2
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true
}