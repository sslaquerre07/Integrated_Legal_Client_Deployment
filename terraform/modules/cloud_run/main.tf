module "service_account" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.2"
  project_id    = var.project_id
  names         = [var.service_name]
  project_roles = var.service_account_project_roles
  display_name  = "Cloud Run Service Account"
}

locals {
  secret_env_vars = flatten([
    for env_var in var.env_secret_vars : [
      for value_from in env_var.value_from : {
        env_name    = env_var.name
        secret_name = value_from.secret_key_ref["name"]
      }
    ]
  ])
}

resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  for_each = {
    for secret in local.secret_env_vars :
    "${secret.env_name}-${secret.secret_name}" => secret
  }

  project   = var.project_id
  secret_id = each.value.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.service_account.email}"
}

# Using a sample image for now, will update to the actual image later
module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.16"

  service_name          = var.service_name
  project_id            = var.project_id
  location              = var.region
  image                 = var.image_name
  ports                 = var.container_port
  env_vars              = var.env_vars
  env_secret_vars       = var.env_secret_vars
  template_annotations  = var.template_annotations
  service_account_email = module.service_account.email

  depends_on = [
    module.service_account,
    google_secret_manager_secret_iam_member.secret_accessor
  ]
}