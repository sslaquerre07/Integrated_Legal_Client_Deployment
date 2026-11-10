# General variables for the Terraform configuration
variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}
variable "region" {
  description = "The GCP region where resources will be created."
  type        = string
  default     = "us-west1"
}
