terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project               = "codemender-public-preview"
  region                = "us-central1"
  user_project_override = true
  billing_project       = "codemender-public-preview"
}
