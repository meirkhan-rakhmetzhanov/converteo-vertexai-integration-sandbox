resource "google_iam_workload_identity_pool" "azure_pool" {
  workload_identity_pool_id = "azure-pool"
  display_name              = "Azure Pool"
}

resource "google_iam_workload_identity_pool_provider" "azure_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.azure_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "azure-provider"

  display_name = "Azure Provider"

  oidc {
    allowed_audiences = ["${var.azure_application}"]
    issuer_uri = "https://sts.windows.net/${var.azure_tenant_id}/"
  }

  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.aud"  = "assertion.aud"
  }
}





# resource "google_service_account" "service-accounts-sg" {
#   project  = google_project.saintgobain-sdx.project_id
#   account_id   = var.service_account_info.name  
#   display_name = var.service_account_info.name
#   description  = var.service_account_info.description
#   disabled     = var.service_account_info.disabled
# }
# # Roles of service accounts
# resource "google_project_iam_member" "service-accounts-project-roles" {
#   project  = google_project.saintgobain-sdx.project_id
#   role   = "roles/aiplatform.user"
#   member = "serviceAccount:${google_service_account.service-accounts-sg.email}"
# }

resource "google_service_account_iam_binding" "wif_impersonation" {
  service_account_id = google_service_account.service-accounts-sg.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.azure_pool.name}/attribute.aud/${var.azure_client_id}"
  ]
}

#projects/1094315014548/locations/global/

    

# gcloud iam workload-identity-pools create-cred-config \
#   projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/azure-pool/providers/azure-provider \
#   --service-account=azure-impersonation-sa@PROJECT_ID.iam.gserviceaccount.com \
#   --output-file=azure-wif.json \
#   --credential-source-file=/path/to/azure/token

# export GOOGLE_APPLICATION_CREDENTIALS=azure-wif.json
# gcloud auth application-default print-access-token

# attribute_condition = "assertion.aud == '${var.azure_client_id}'"

# curl -H Metadata:true \
# "http://169.254.169.254/metadata/identity/oauth2/token?resource=api://AzureADTokenExchange"