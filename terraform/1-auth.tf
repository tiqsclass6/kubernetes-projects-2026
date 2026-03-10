terraform {
  required_version = ">= 1.10.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }

  backend "gcs" {
    bucket = "tiqs-kubernetes"
    prefix = "project-4/terraform/state"
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("../class-6-5-tiqs-095c33bf9f57.json")

  default_labels = local.common_labels
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = file("../class-6-5-tiqs-095c33bf9f57.json")

  default_labels = local.common_labels
}