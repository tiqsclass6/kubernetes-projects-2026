terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use latest version if possible
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

  }

  backend "s3" {
    bucket  = "kubernetes-assignment-state-files"
    key     = "theolabs/kubernetes-class/project02.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


provider "aws" {
  region  = var.region
  profile = "default"
}
