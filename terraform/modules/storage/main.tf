locals {
  bucket_prefix   = "ilcp"
  bucket_suffixes = toset(["dev"])
}

resource "google_storage_bucket" "cloud_storage" {
  for_each                    = local.bucket_suffixes
  name                        = "${local.bucket_prefix}-${each.value}-bucket"
  storage_class               = "STANDARD"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  # Prevent deletion or modification of objects for a set period (e.g., 7 years)
  retention_policy {
    retention_period = 220752000 # 7 years in seconds (7 * 365 * 86400)
    is_locked        = false     # Set to true ONLY when ready to permanently lock the policy
  }
}