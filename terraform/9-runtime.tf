# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# Update kubeconfig for the GKE cluster
resource "null_resource" "update_kubeconfig" {
  count = var.enable_kubeconfig ? 1 : 0

  # Use local-exec provisioner to run gcloud command to update kubeconfig
  # This allows kubectl to communicate with the GKE cluster after creation
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.kong.name} --zone ${var.region}-b --project ${var.project_id}"
  }

  depends_on = [google_container_cluster.kong]
}