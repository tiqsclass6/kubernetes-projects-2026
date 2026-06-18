# data "google_client_config" "current" {}

# https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http
# Retrieve the current public IP address of the machine running Terraform to restrict access to the GKE cluster
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

# https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks
# https://cloud.google.com/kubernetes-engine/docs/how-to/api-server-authorized-networks
# https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks#add
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#authorized_networks_config
locals {
  current_public_ip_cidr = "${trimspace(data.http.my_ip.response_body)}/32"
  workload_pool          = "${var.project_id}.svc.id.goog"
}