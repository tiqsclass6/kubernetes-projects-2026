terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket  = "kubernetes-assignment-state-files"           # Name of the S3 bucket
    key     = "theolabs/kubernetes-class/project06.tfstate" # The name of the state file in the bucket
    region  = "us-east-1"                                   # Use a variable for the region
    encrypt = true                                          # Enable server-side encryption (optional but recommended)
  }
}


provider "aws" {
  region  = var.region
  profile = "default"
}
