resource "google_api_gateway_api" "hello" {
  provider     = google-beta
  api_id       = var.api_gateway_id
  project      = var.gcp_project_name
  display_name = var.api_display_name
}

resource "google_api_gateway_api_config" "hello" {
  provider     = google-beta
  api          = google_api_gateway_api.hello.api_id
  project      = var.gcp_project_name
  display_name = var.api_display_name

  openapi_documents {
    document {
      path     = "hello.yaml"
      contents = filebase64("hello.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  gateway_config {
    backend_config {
      google_service_account = google_service_account.hello_gateway.email
    }
  }
}

resource "google_api_gateway_gateway" "hello" {
  provider = google-beta
  region   = var.gcp_region
  project  = var.gcp_project_name

  api_config = google_api_gateway_api_config.hello.id

  gateway_id   = google_api_gateway_api.hello.api_id
  display_name = var.api_display_name
}

