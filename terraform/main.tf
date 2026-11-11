module "cloud_sql" {
  source     = "./modules/cloud-sql"
  project_id = var.project_id
  region     = var.region
}

module "cloud_storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region
}

module "frontend" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ilcp-frontend"

  image_name     = "nginx:alpine"
  container_port = { name = "http1", port = 80 }
  env_vars = [
    { name = "API_URL", value = module.backend.service_url }
  ]

  members = ["allUsers"]
}

module "backend" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ilcp-backend"

  image_name                    = "mendhak/http-https-echo:latest"
  container_port                = { name = "http1", port = 8080 }
  service_account_project_roles = ["${var.project_id}=>roles/cloudsql.client"]
  template_annotations = {
    "run.googleapis.com/cloudsql-instances" = module.cloud_sql.postgresql_connection_name
  }

  env_vars = [
    {
      name  = "DATABASE_URL"
      value = "postgresql://ilcp_user@/dev?host=/cloudsql/${module.cloud_sql.postgresql_connection_name}"
    },
    { name = "GCP_PROJECT", value = var.project_id },
    { name = "GCP_BUCKET", value = module.cloud_storage.ids["dev"] }
  ]
  env_secret_vars = [
    {
      name = "DB_PASSWORD"
      value_from = [
        {
          secret_key_ref = {
            name = "DB_PASSWORD"
            key  = "latest"
          }
        }
      ]
    }
  ]
}

resource "google_cloud_run_service_iam_member" "authenticated_backend_access" {
  project  = var.project_id
  location = var.region
  role     = "roles/run.invoker"
  service  = module.backend.service_name

  member = "serviceAccount:${module.frontend.service_account_email}"
}