resource "google_api_gateway_api" "hello" {
  provider     = google-beta
  api_id       = var.api_gateway_id
  project      = var.gcp_project_name
  display_name = var.api_display_name
}

locals {
  openapi_spec = <<-EOT
swagger: "2.0"
info:
  title: cloudruntest
  description: "Test Cloud Run Function."
  version: "1.0.0"
schemes:
  - "https"
x-google-backend:
  address: ${google_cloud_run_v2_service.hello.uri}
produces:
- application/json
paths:
  "/hello":
    get:
      description: "Say hello"
      operationId: "hello"
      parameters:
        -
          name: name
          in: query
          required: true
          type: string
      responses:
        200:
          description: "Success."
          schema:
            type: string
        400:
          description: "The name is invalid or missing."
  EOT
}

resource "local_file" "openapi_spec_yaml" {
  filename = "hello_openapi.yaml"
  content  = local.openapi_spec
}

resource "google_api_gateway_api_config" "hello" {
  provider     = google-beta
  api          = google_api_gateway_api.hello.api_id
  project      = var.gcp_project_name
  display_name = var.api_display_name

  openapi_documents {
    document {
      path     = local_file.openapi_spec_yaml.filename
      contents = base64encode(local.openapi_spec)
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

