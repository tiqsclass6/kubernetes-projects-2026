resource "google_service_account" "nodes" {
  account_id   = "gke-node-group-nodes"
  display_name = "GKE Node Group Nodes"
}

resource "google_project_iam_member" "nodes_default_node_sa" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_resource_metadata_writer" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "nodes_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_container_node_pool" "private-nodes" {
  name     = "${var.cluster_name}-private-nodes"
  location = "${var.region}-b"
  cluster  = google_container_cluster.demo.name

  node_locations = [
    local.zone1,
    local.zone2
  ]

  initial_node_count = var.node_desired_count

  autoscaling {
    total_min_node_count = var.node_min_count
    total_max_node_count = var.node_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 1
  }

  node_config {
    machine_type    = var.node_machine_type
    disk_size_gb    = var.node_disk_size_gb
    disk_type       = var.node_disk_type
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      role = "general"
    }

    tags = [
      "gke",
      "private-nodes"
    ]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  depends_on = [
    google_project_iam_member.nodes_default_node_sa,
    google_project_iam_member.nodes_log_writer,
    google_project_iam_member.nodes_metric_writer,
    google_project_iam_member.nodes_resource_metadata_writer,
    google_project_iam_member.nodes_artifact_registry_reader
  ]

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}