resource "google_cloud_run_v2_service" "hello" {
  project             = var.gcp_project_name
  name                = "hello"
  location            = var.gcp_region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  depends_on = [google_service_account.hello_cloudrun_service, google_project_service.run_api]

  template {
    service_account = google_service_account.hello_cloudrun_service.email
    scaling {
      min_instance_count = 1
      max_instance_count = 100
    }
    containers {
      image   = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_name}/hello/${var.cloudrun_container_id}"
      command = ["/app/hello"]
      startup_probe {
        failure_threshold     = 1
        initial_delay_seconds = 1
        period_seconds        = 10
        timeout_seconds       = 10

        tcp_socket {
          port = 8080
        }
      }
    }
  }
}

# Let the API Gateway service account call the CloudRun service
resource "google_cloud_run_service_iam_member" "allow_gateway_invoke_cloud_run_service" {
  project  = var.gcp_project_name
  location = var.gcp_region
  service  = google_cloud_run_v2_service.hello.name
  member   = "serviceAccount:${google_service_account.hello_gateway.email}"
  role     = "roles/run.invoker"
}
