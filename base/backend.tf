resource "google_storage_bucket" "tf_state" {
  name     = "sg-terraform-state-bucket"
  location = var.region

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  force_destroy = false

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

terraform {
  backend "gcs" {
    bucket  = "sg-terraform-state-bucket"
    prefix  = "terraform/state"
  }
}