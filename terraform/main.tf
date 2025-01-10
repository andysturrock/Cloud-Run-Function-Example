terraform {
  required_providers {
    google = {
      configuration_aliases = [google]
    }
    google-beta = {
      configuration_aliases = [google-beta]
    }
  }
}

terraform {
  backend "gcs" {
  }
}
