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
}