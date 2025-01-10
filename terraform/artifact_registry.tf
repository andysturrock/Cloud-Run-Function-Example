resource "google_artifact_registry_repository" "hello" {
  project       = var.gcp_project_name
  location      = var.gcp_region
  repository_id = "hello"
  description   = "Repo for images used in hello service"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}

# Service account for the artifact repo
resource "google_project_service_identity" "artifact_registry" {
  provider = google-beta
  project  = var.gcp_project_name
  service  = "artifactregistry.googleapis.com"
}

# Give the Terraform service account access to the repo.
# This is a new requirement from Google, starting Jan 2025.
resource "google_artifact_registry_repository_iam_member" "member" {
  project    = google_artifact_registry_repository.hello.project
  location   = google_artifact_registry_repository.hello.location
  repository = google_artifact_registry_repository.hello.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.terraform_service_account}"
}