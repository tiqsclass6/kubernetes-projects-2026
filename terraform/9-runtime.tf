resource "null_resource" "update_kubeconfig" {
  count = var.enable_kubeconfig ? 1 : 0

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.demo.name} --region ${var.region} --project ${var.project_id}"
  }

  depends_on = [google_container_cluster.demo]
}