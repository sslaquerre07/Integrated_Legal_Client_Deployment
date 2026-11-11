output "service_url" {
  description = "The URL of the Cloud Run service"
  value       = module.cloud_run.service_url
}
output "service_name" {
  description = "The name of the Cloud Run service"
  value       = module.cloud_run.service_name
}

output "service_account_email" {
  description = "The email of the Cloud Run service account"
  value       = module.service_account.email
}