# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service
# Enable Artifact Registry API for the project
resource "google_project_service" "artifactregistry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository
# Create an Artifact Registry repository for container images
resource "google_artifact_registry_repository" "kong" {
  provider = google-beta

  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_repository_id
  description   = "Container images for ${var.cluster_name}"
  format        = var.artifact_registry_format

  depends_on = [
    google_project_service.artifactregistry
  ]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member
# Grant the GKE nodes service account read access to the Artifact Registry repository
resource "google_artifact_registry_repository_iam_member" "nodes_reader" {
  location   = google_artifact_registry_repository.kong.location
  repository = google_artifact_registry_repository.kong.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.nodes.email}"
}