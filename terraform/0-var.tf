variable "enable_kubeconfig" {
  default     = true
  description = "Set to false to skip local kubeconfig update"
}

variable "region" {
  default = "us-east-1"
}

# core VPC paramters 
variable "vpc_cidr" {
  default = "10.100.0.0/16"
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

locals {
  zone1 = "${var.region}a"
  zone2 = "${var.region}b"
}

variable "cluster_name" {
  default     = "demo"
  type        = string
  description = "AWS EKS CLuster Name"
  nullable    = false
}

# EKS OIDC ROOT CA Thumbprint - valid until 2037
variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

# EKS OIDC URL - can be obtained from AWS Console or CLI
variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}

# Kong parameters
variable "kong_namespace" {
  description = "Namespace for Kong"
  type        = string
  default     = "kong"
}

# Hello application parameters
variable "app_namespace" {
  description = "Namespace for the hello application"
  type        = string
  default     = "apps"
}

# Number of replicas for the hello application
variable "hello_replicas" {
  description = "Replica count for hello app"
  type        = number
  default     = 2
}

# Common tags for all resources
variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    Project = "kong-lab"
    Owner   = "student"
  }
}