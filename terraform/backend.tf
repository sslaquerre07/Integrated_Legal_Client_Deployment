terraform {
  backend "gcs" {
    bucket = "integrated-legal-client-portal-tfstate"
    prefix = "terraform/state"
  }
}