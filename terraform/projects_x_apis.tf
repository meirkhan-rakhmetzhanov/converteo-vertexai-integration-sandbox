
# SPECIAL PROJECTS
# Imported
resource "google_project" "saintgobain-sdx" {
  name                = var.projects.saintgobain-sdx.name
  project_id          = var.projects.saintgobain-sdx.id
  auto_create_network = false
  org_id              = "802772127372"
  lifecycle {
    prevent_destroy = true
  }
}

# APIs for Infra-Genesis
locals {
  enabled_apis_on_saintgobain-sdx = [
    "container.googleapis.com",            # CREATED - Builds and manages container-based applications, powered by the open source Kubernetes technology.
    "aiplatform.googleapis.com",
  ]
}

resource "google_project_service" "enable-apis-on-saintgobain-sdx" {
  project                    = google_project.saintgobain-sdx.project_id
  for_each                   = toset(local.enabled_apis_on_saintgobain-sdx)
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}



 

