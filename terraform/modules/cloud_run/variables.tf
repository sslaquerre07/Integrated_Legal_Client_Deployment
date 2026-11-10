# Generic variables for the Cloud Run module
variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}
variable "region" {
  description = "The GCP region where resources will be created."
  type        = string
}

# Cloud Run specific variables
variable "service_name" {
  description = "The unique name of the Cloud Run service and its service account."
  type        = string
}

variable "image_name" {
  description = "The name of the container image to deploy to Cloud Run."
  type        = string
}

variable "service_account_project_roles" {
  description = "Project IAM roles to grant to the service account, in project=>role form."
  type        = list(string)
  default     = []
}

variable "template_annotations" {
  description = "Cloud Run revision template annotations."
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "The port on which the container listens for requests."
  type = object({
    name = string
    port = number
  })
}
variable "env_vars" {
  description = "Environment variables to set in the Cloud Run service."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
variable "env_secret_vars" {
  description = "Environment variables to set from Secret Manager."
  type = list(object({
    name = string
    value_from = set(object({
      secret_key_ref = map(string)
    }))
  }))
  default = []
}
variable "members" {
  description = "IAM members to grant access to the Cloud Run service account."
  type        = list(string)
  default     = []
}