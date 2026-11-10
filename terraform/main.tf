data "google_secret_manager_secret_version" "db_password" {
  project = var.project_id
  secret  = "DB_PASSWORD"
  version = "latest"
}

module "cloud_storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region
}

module "cloud_sql" {
  source      = "./modules/cloud-sql"
  project_id  = var.project_id
  region      = var.region
  db_password = data.google_secret_manager_secret_version.db_password.secret_data
}

module "frontend" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ilcp-frontend"

  image_name     = "us-docker.pkg.dev/cloudrun/container/hello"
  container_port = { name = "http1", port = 8080 }
  env_vars = [
    { name = "API_URL", value = "https://api.example.com" }
  ]
  members = ["allUsers"]
}

module "backend" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ilcp-backend"

  image_name                    = "us-docker.pkg.dev/cloudrun/container/hello"
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