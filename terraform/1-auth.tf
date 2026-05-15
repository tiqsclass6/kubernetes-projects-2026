terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
      version = "~> 2.32"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  backend "s3" {
    bucket  = "kubernetes-assignment-state-files"
    key     = "theolabs/kubernetes-class/project05.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}