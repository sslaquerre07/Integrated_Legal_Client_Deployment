output "ids" {
  description = "The IDs of the cloud storage resources."
  value       = { for suffix, bucket in google_storage_bucket.cloud_storage : suffix => bucket.name }
}