variable "enable_kubeconfig" {
  default     = true
  description = "Set to false to skip local kubeconfig update"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "class-6-5-tiqs"
}

variable "region" {
  description = "GCP region for resource deployment"
  type        = string
  default     = "us-central1"
}

# core VPC parameters
variable "vpc_cidr" {
  description = "CIDR block for the VPC network"
  type        = string
  default     = "10.100.0.0/16"
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for all subnets by name"
  type = object({
    private_zone1 = string
    private_zone2 = string
    public_zone1  = string
    public_zone2  = string
  })
  default = {
    private_zone1 = "10.100.0.0/19"
    private_zone2 = "10.100.32.0/19"
    public_zone1  = "10.100.64.0/19"
    public_zone2  = "10.100.96.0/19"
  }
}

variable "gke_secondary_ranges" {
  description = "Secondary CIDR ranges used by GKE pods and services"
  type = object({
    pods     = string
    services = string
  })
  default = {
    pods     = "10.101.0.0/16"
    services = "10.102.0.0/20"
  }
}

variable "master_ipv4_cidr_block" {
  description = "Private control plane CIDR block for the GKE master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "cluster_name" {
  default     = "kong"
  type        = string
  description = "GKE cluster name"
  nullable    = false
}

variable "node_machine_type" {
  description = "Machine type for GKE worker nodes"
  type        = string
  default     = "n2-standard-2"
}

variable "node_disk_size_gb" {
  description = "Boot disk size in GB for GKE nodes"
  type        = number
  default     = 50
}

variable "node_disk_type" {
  description = "Boot disk type for GKE nodes"
  type        = string
  default     = "pd-balanced"
}

variable "node_min_count" {
  description = "Minimum total node count for autoscaling"
  type        = number
  default     = 2
}

variable "node_max_count" {
  description = "Maximum total node count for autoscaling"
  type        = number
  default     = 5
}

variable "node_desired_count" {
  description = "Initial node count for node pool creation"
  type        = number
  default     = 3
}

variable "authorized_networks" {
  description = "CIDR blocks allowed to reach the public GKE control plane endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

locals {
  zone1 = "${var.region}-a"
  zone2 = "${var.region}-b"

  common_labels = {
    cluster = var.cluster_name
    managed = "terraform"
  }
}