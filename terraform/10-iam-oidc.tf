data "google_client_config" "current" {}

locals {
  workload_pool = "${var.project_id}.svc.id.goog"
}