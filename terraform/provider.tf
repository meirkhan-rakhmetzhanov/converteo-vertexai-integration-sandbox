terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.85.0"
    }
  }
}

provider "google" {
project = var.project_id
region = var.region
zone = var.zone
impersonate_service_account = var.tf_service_account
}