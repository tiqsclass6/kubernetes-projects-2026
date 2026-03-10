output "gke_cluster_info" {
  value = {
    name        = google_container_cluster.demo.name
    endpoint    = google_container_cluster.demo.endpoint
    id          = google_container_cluster.demo.id
    location    = google_container_cluster.demo.location
    description = "GKE cluster info"
  }
}

output "gke_node_pool_summary" {
  value = format(
    "Node pool '%s' runs machine type %s with autoscaling range %d-%d",
    google_container_node_pool.private-nodes.name,
    google_container_node_pool.private-nodes.node_config[0].machine_type,
    google_container_node_pool.private-nodes.autoscaling[0].total_min_node_count,
    google_container_node_pool.private-nodes.autoscaling[0].total_max_node_count
  )
  description = "Summary of GKE node pool configuration"
}

output "workload_identity" {
  description = "GKE Workload Identity configuration"
  value = {
    workload_pool = local.workload_pool
    project_id    = var.project_id
  }
}

output "gke_storage_classes" {
  description = "Custom CSI-backed storage classes created for GKE"
  value = [
    kubernetes_storage_class_v1.premium_rwo.metadata[0].name,
    kubernetes_storage_class_v1.standard_rwo.metadata[0].name
  ]
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository for GKE images"
  value = {
    id       = google_artifact_registry_repository.demo.id
    name     = google_artifact_registry_repository.demo.name
    location = google_artifact_registry_repository.demo.location
    format   = google_artifact_registry_repository.demo.format
  }
}

output "artifact_registry_docker_repo_url" {
  description = "Base Docker repository URL for Artifact Registry"
  value       = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository_id}"
}

output "firewall_rule_names" {
  description = "Firewall rules created for the GKE environment"
  value = compact([
    google_compute_firewall.allow_internal.name,
    try(google_compute_firewall.allow_ssh_to_private_nodes[0].name, null),
    try(google_compute_firewall.allow_http_to_private_nodes[0].name, null),
    try(google_compute_firewall.allow_https_to_private_nodes[0].name, null)
  ])
}