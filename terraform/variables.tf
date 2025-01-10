variable "gcp_project_name" {
  type        = string
  description = "GCP project name"
}

variable "gcp_region" {
  type        = string
  description = "GCP region"
}

variable "cloudrun_container_id" {
  type        = string
  description = "Container for API Gateway"
}

variable "api_gateway_id" {
  type        = string
  description = "ID for the API gateway"
}

variable "api_display_name" {
  type        = string
  description = "Display name for the API"
}

variable "terraform_service_account" {
  type        = string
  description = "Service Account to run terraform, deploy containers to CloudRun etc"
}
