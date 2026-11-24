resource "google_cloud_run_v2_job" "this" {
  name     = var.name
  location = var.region
  project  = var.project_id

  template {
    template {
      service_account = var.service_account_email

      dynamic "vpc_access" {
        for_each = var.vpc_access != null ? [var.vpc_access] : []
        content {
          network_interfaces {
            network    = vpc_access.value.network
            subnetwork = vpc_access.value.subnetwork
          }
          egress = vpc_access.value.egress
        }
      }

      dynamic "volumes" {
        for_each = length(var.cloud_sql_instances) > 0 ? [1] : []
        content {
          name = "cloudsql"
          cloud_sql_instance {
            instances = var.cloud_sql_instances
          }
        }
      }

      containers {
        image   = var.image
        command = length(var.command) > 0 ? var.command : null
        args    = length(var.args) > 0 ? var.args : null

        dynamic "volume_mounts" {
          for_each = length(var.cloud_sql_instances) > 0 ? [1] : []
          content {
            name       = "cloudsql"
            mount_path = "/cloudsql"
          }
        }

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = var.secret_env_vars
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = env.value.secret
                version = env.value.version
              }
            }
          }
        }
      }
    }
  }
}