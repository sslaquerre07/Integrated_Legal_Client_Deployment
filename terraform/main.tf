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

  image_name     = "us-west1-docker.pkg.dev/integrated-legal-client-portal/application-images-fe-and-be/frontend:e834fb8bae3bf5efd6a2e65e5798d5984588b241"
  container_port = { name = "http1", port = 3000 }
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

  image_name                    = "us-west1-docker.pkg.dev/integrated-legal-client-portal/application-images-fe-and-be/backend:1e06c0a8d833ccacc24fa2e8977a12e2ed466976"
  container_port                = { name = "http1", port = 3001 }
  service_account_project_roles = ["${var.project_id}=>roles/cloudsql.client"]
  template_annotations = {
    "run.googleapis.com/cloudsql-instances" = module.cloud_sql.postgresql_connection_name
  }

  env_vars = [
    { name = "DB_HOST", value = module.cloud_sql.postgresql_connection_name },
    { name = "DB_NAME", value = "dev" },
    { name = "DB_USER", value = "ilcp_user" },
    { name = "GCP_PROJECT_ID", value = var.project_id },
    { name = "STORAGE_BUCKET_NAME", value = module.cloud_storage.ids["dev"] }
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