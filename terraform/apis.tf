# Enable the Cloud Run API
resource "google_project_service" "run_api" {
  project = var.gcp_project_name
  service = "run.googleapis.com"
  // Don't disable this API when we run tf destroy.
  disable_on_destroy = false
}

# Enable the API Gateway API
resource "google_project_service" "apigateway_api" {
  project = var.gcp_project_name
  service = "apigateway.googleapis.com"
  // Don't disable this API when we run tf destroy.
  disable_on_destroy = false
}

# Need service control API to use API Gateway
resource "google_project_service" "servicecontrol_api" {
  project = var.gcp_project_name
  service = "servicecontrol.googleapis.com"
  // Don't disable this API when we run tf destroy.
  disable_on_destroy = false
}

# Need service management API to use API Gateway
resource "google_project_service" "servicemanagement_api" {
  project = var.gcp_project_name
  service = "servicemanagement.googleapis.com"
  // Don't disable this API when we run tf destroy.
  disable_on_destroy = false
}

# Enable the Artifact Registry API
resource "google_project_service" "artifactregistry_api" {
  project = var.gcp_project_name
  service = "artifactregistry.googleapis.com"
  // Don't disable this API when we run tf destroy.
  disable_on_destroy = false
}

# Enable the IAM API
resource "google_project_service" "iam_api" {
  project = var.gcp_project_name
  service = "iam.googleapis.com"
  // Don't disable this API when we run tf destroy.
  disable_on_destroy = false
}
