# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
# Allow internal traffic between all subnets and GKE secondary ranges
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.cluster_name}-allow-internal"
  network = google_compute_network.main.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.vpc_cidr,
    var.gke_secondary_ranges.pods,
    var.gke_secondary_ranges.services
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  description = "Allow internal east-west traffic inside the VPC and GKE secondary ranges"
}

# Allow SSH access to private nodes from admin networks if needed
resource "google_compute_firewall" "allow_ssh_to_private_nodes" {
  count = length(var.admin_source_ranges) > 0 ? 1 : 0

  name    = "${var.cluster_name}-allow-ssh-private-nodes"
  network = google_compute_network.main.name

  direction = "INGRESS"
  priority  = 1100

  source_ranges = var.admin_source_ranges
  target_tags   = ["private-nodes"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description = "Optional SSH access to private GKE nodes for controlled admin networks"
}

# Allow HTTP access to workloads exposed directly on nodes if needed
resource "google_compute_firewall" "allow_http_to_private_nodes" {
  count = length(var.http_source_ranges) > 0 ? 1 : 0

  name    = "${var.cluster_name}-allow-http-private-nodes"
  network = google_compute_network.main.name

  direction = "INGRESS"
  priority  = 1200

  source_ranges = var.http_source_ranges
  target_tags   = ["private-nodes"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  description = "Optional HTTP access to workloads exposed directly on nodes"
}

# Allow HTTPS access to workloads exposed directly on nodes if needed
resource "google_compute_firewall" "allow_https_to_private_nodes" {
  count = length(var.https_source_ranges) > 0 ? 1 : 0

  name    = "${var.cluster_name}-allow-https-private-nodes"
  network = google_compute_network.main.name

  direction = "INGRESS"
  priority  = 1201

  source_ranges = var.https_source_ranges
  target_tags   = ["private-nodes"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  description = "Optional HTTPS access to workloads exposed directly on nodes"
}