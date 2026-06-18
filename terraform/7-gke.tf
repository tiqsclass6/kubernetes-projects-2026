# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service
# Enable required APIs for GKE cluster
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iamcredentials" {
  project            = var.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sts" {
  project            = var.project_id
  service            = "sts.googleapis.com"
  disable_on_destroy = false
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
# Create a GKE cluster with private nodes and VPC-native networking
resource "google_container_cluster" "kong" {
  provider = google-beta

  name     = var.cluster_name
  location = "${var.region}-b"

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.private_zone1.name

  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = false
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.cluster_name}-pods"
    services_secondary_range_name = "${var.cluster_name}-services"
  }

  # Network policy for pod-to-pod communication and ingress/egress control
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Workload Identity for secure service account access from GKE workloads
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Addons for HTTP load balancing, horizontal pod autoscaling, and GCE persistent disk CSI driver
  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  deletion_protection = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container,
    google_project_service.iamcredentials,
    google_project_service.sts,
    google_compute_router_nat.nat
  ]
}