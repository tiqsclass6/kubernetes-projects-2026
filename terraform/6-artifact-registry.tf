variable "artifact_registry_repository_id" {
  description = "Artifact Registry repository ID"
  type        = string
  default     = "demo"
}

variable "artifact_registry_location" {
  description = "Artifact Registry repository location"
  type        = string
  default     = "us-east1"
}

variable "artifact_registry_format" {
  description = "Artifact Registry repository format"
  type        = string
  default     = "DOCKER"
}

resource "google_project_service" "artifactregistry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "demo" {
  provider = google-beta

  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_repository_id
  description   = "Container images for ${var.cluster_name}"
  format        = var.artifact_registry_format

  depends_on = [
    google_project_service.artifactregistry
  ]
}

resource "google_artifact_registry_repository_iam_member" "nodes_reader" {
  location   = google_artifact_registry_repository.demo.location
  repository = google_artifact_registry_repository.demo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.nodes.email}"
}