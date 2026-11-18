output "service_url" {
  description = "The URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloud_run.uri
}
output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_v2_service.cloud_run.name
}

output "service_account_email" {
  description = "The email of the Cloud Run service account"
  value       = module.service_account.email
}