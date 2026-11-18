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

resource "google_cloud_run_v2_service" "cloud_run" {
  name     = var.service_name
  project  = var.project_id
  location = var.region
  ingress  = var.ingress

  template {
    service_account = module.service_account.email

    containers {
      image = var.image_name

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      dynamic "env" {
        for_each = var.env_secret_vars
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = one(env.value.value_from).secret_key_ref["name"]
              version = one(env.value.value_from).secret_key_ref["key"]
            }
          }
        }
      }

      ports {
        name           = var.container_port.name
        container_port = var.container_port.port
      }
    }

    vpc_access {
      network_interfaces {
        network    = var.vpc_network
        subnetwork = var.vpc_subnetwork
      }
      egress = var.vpc_egress
    }
  }

  depends_on = [
    module.service_account,
    google_secret_manager_secret_iam_member.secret_accessor
  ]
}

resource "google_cloud_run_v2_service_iam_member" "cloud_run_member" {
  for_each = toset(var.members)

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.cloud_run.name
  role     = "roles/run.invoker"
  member   = each.value
}