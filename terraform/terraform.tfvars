project_id   = "class-6-5-tiqs"
region       = "us-central1"
cluster_name = "kong"

enable_kubeconfig = true

vpc_cidr = "10.100.0.0/16"

subnet_cidr_blocks = {
  private_zone1 = "10.100.0.0/19"
  private_zone2 = "10.100.32.0/19"
  public_zone1  = "10.100.64.0/19"
  public_zone2  = "10.100.96.0/19"
}

gke_secondary_ranges = {
  pods     = "10.101.0.0/16"
  services = "10.102.0.0/20"
}

master_ipv4_cidr_block = "172.16.0.0/28"

node_machine_type = "e2-standard-2"
node_disk_size_gb = 50
node_disk_type    = "pd-balanced"

node_desired_count = 3
node_min_count     = 2
node_max_count     = 5

authorized_networks = [
  {
    cidr_block   = "98.176.213.95/32"
    display_name = "admin-laptop"
  }
]

admin_source_ranges = [
  "98.176.213.95/32"
]

http_source_ranges = [
  "0.0.0.0/0"
]

https_source_ranges = [
  "0.0.0.0/0"
]

artifact_registry_repository_id = "kong"
artifact_registry_location      = "us-central1"
artifact_registry_format        = "DOCKER"