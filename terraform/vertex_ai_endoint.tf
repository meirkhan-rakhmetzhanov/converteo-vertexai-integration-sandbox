#for ML models 
resource "google_vertex_ai_endpoint" "saint-gobain-endpoint" {
  name         = "vertex-endpoint-saint-gobain"
  display_name = "saint-gobain-vertex-endpoint"
  description  = "Saint gobain vertex  AI endpoint"
  location     = var.region
  region       = var.region
  labels       = {
    label-one = "prod"
  }
  private_service_connect_config {
    enable_private_service_connect = true
    project_allowlist = [
      google_project.saintgobain-sdx.project_id
    ]

    psc_automation_configs {
      project_id = google_project.saintgobain-sdx.project_id
      network    = google_compute_network.main-vpc-network.id
    }
  }
}

############### create service account on this project
resource "google_service_account" "service-accounts-sg" {
  project  = google_project.saintgobain-sdx.project_id
  account_id   = var.service_account_info.name  
  display_name = var.service_account_info.name
  description  = var.service_account_info.description
  disabled     = var.service_account_info.disabled
}
# Roles of service accounts
resource "google_project_iam_member" "service-accounts-project-roles" {
  project  = google_project.saintgobain-sdx.project_id
  role   = "roles/aiplatform.user"
  member = "serviceAccount:${google_service_account.service-accounts-sg.email}"
}
#for private service connect
resource "google_compute_address" "psc_ip" {
  name         = "vertex-ai-psc-ip"
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = google_compute_subnetwork.main-vpc-subnetworks["subnetwork_for_prod"].id
}

# resource "google_compute_network_attachment" "psc_attachment" {
#   name                  = "psc-network-attachment"
#   region                = var.region

#   connection_preference = "ACCEPT_MANUAL"

#   subnetworks = [
#     google_compute_subnetwork.main-vpc-subnetworks["subnetwork_for_prod"].id
#   ]
# }

#not working
# resource "google_compute_forwarding_rule" "psc" {
#   name                  = "vertex-ai-psc"
#   region                = var.region
#   network               = google_compute_network.main-vpc-network.id
#   subnetwork            = google_compute_subnetwork.main-vpc-subnetworks["subnetwork_for_prod"].id
#   ip_address            = google_compute_address.psc_ip.id
#   load_balancing_scheme = ""
#   # service attachment Vertex AI (géré par Google)
#   target = "projects/${google_project.saintgobain-sdx.project_id}/regions/${var.region}/serviceAttachments/aiplatform"
#   allow_psc_global_access = true
# }

# 
# ************************
# resource "google_vertex_ai_endpoint" "endpoint" {
#   name         = "multi-model-endpoint"
#   display_name = "multi-model-endpoint"
#   location     = "europe-west4"
# }

# resource "google_vertex_ai_endpoint_deployed_model" "model_a" {
#   endpoint = google_vertex_ai_endpoint.endpoint.id

#   deployed_model {
#     model = "projects/xxx/models/modelA"
#     display_name = "model-a"

#     dedicated_resources {
#       machine_spec {
#         machine_type = "n1-standard-2"
#       }
#       min_replica_count = 1
#       max_replica_count = 1
#     }
#   }

#   traffic_split = {
#     "0" = 80
#   }
# }








