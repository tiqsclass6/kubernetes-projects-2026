# data "google_client_config" "current" {}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  current_public_ip_cidr = "${trimspace(data.http.my_ip.response_body)}/32"
  workload_pool          = "${var.project_id}.svc.id.goog"
}