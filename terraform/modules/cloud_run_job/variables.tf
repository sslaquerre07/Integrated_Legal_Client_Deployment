# modules/cloud-run-job/variables.tf
variable "name" {
  type        = string
  description = "Name of the Cloud Run Job"
}
variable "region" {
  type        = string
  description = "Region Job Deployed In"
}
variable "project_id" {
  type = string
}

variable "image" {
  type        = string
  description = "Image the job should run on"
}
variable "command" {
  type        = list(string)
  default     = []
  description = "Commands that the job should run"
}
variable "args" {
  type        = list(string)
  default     = []
  description = "Arguments for the command"
}

variable "service_account_email" {
  type        = string
  description = "Service Account Running the Job (Must have the correct permissions)"
}
variable "cloud_sql_instances" {
  type    = list(string)
  default = []
}
variable "env_vars" {
  type    = map(string)
  default = {}
}
variable "secret_env_vars" {
  type = map(object({
    secret  = string
    version = optional(string, "latest")
  }))
  default = {}
}
variable "vpc_access" {
  description = "Direct VPC Egress network configuration for private resources."
  type = object({
    network    = string
    subnetwork = string
    egress     = optional(string, "PRIVATE_RANGES_ONLY")
  })
  default = null
}