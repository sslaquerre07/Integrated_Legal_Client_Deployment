variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}
variable "region" {
  description = "The GCP region where resources will be created."
  type        = string
}
variable "vpc_network_self_link" {
  description = "Self-link of the VPC network used for private Cloud SQL connectivity."
  type        = string
}
