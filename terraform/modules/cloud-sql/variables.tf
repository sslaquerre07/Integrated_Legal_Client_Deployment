variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}
variable "region" {
  description = "The GCP region where resources will be created."
  type        = string
}

variable "db_password" {
  description = "The password for the Cloud SQL database."
  type        = string
  sensitive   = true
}