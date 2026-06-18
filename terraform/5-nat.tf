# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
# Cloud Router for NAT
resource "google_compute_router" "nat" {
  name    = "nat"
  region  = var.region
  network = google_compute_network.main.id
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
# Cloud NAT for private GKE nodes to access the internet
resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.nat.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_zone1.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.private_zone2.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}