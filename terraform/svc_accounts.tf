resource "google_service_account" "hello_gateway" {
  project = var.gcp_project_name
  # GCP account ids must match "^[a-z](?:[-a-z0-9]{4,28}[a-z0-9])$".
  # So dashes rather than underscores as separators.
  account_id   = "hello-gateway"
  display_name = "Service Account for running hello API Gateway"
}

resource "google_service_account" "hello_cloudrun_service" {
  project = var.gcp_project_name
  # GCP account ids must match "^[a-z](?:[-a-z0-9]{4,28}[a-z0-9])$".
  # So dashes rather than underscores as separators.
  account_id   = "hello-cloudrun-service"
  display_name = "Service Account for running hello Cloud Run service"
}