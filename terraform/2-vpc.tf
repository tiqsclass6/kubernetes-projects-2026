# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
# Custom VPC network
resource "google_compute_network" "main" {
  name                    = "main"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}