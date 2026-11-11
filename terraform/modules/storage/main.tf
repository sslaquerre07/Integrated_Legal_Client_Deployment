module "cloud_storage" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 11.0"
  location = var.region

  project_id = var.project_id

  prefix = "ilcp-storage-bucket"
  names  = ["dev"]

  storage_class = "STANDARD"

}