# Container images
locals {
  frontend_image = "us-west1-docker.pkg.dev/integrated-legal-client-portal/application-images-fe-and-be/frontend:139b14b7b26e99063494d58913e90371c901a6c1"
  backend_image  = "us-west1-docker.pkg.dev/integrated-legal-client-portal/application-images-fe-and-be/backend:139b14b7b26e99063494d58913e90371c901a6c1"
}

# Network and data services
module "cloud_vpc" {
  source     = "./modules/cloud_network"
  project_id = var.project_id
  region     = var.region
}
module "cloud_sql" {
  source                = "./modules/cloud-sql"
  project_id            = var.project_id
  region                = var.region
  vpc_network_self_link = module.cloud_vpc.network_self_link
}
module "cloud_storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region
}

# Cloud Run services and migration job
module "frontend" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ilcp-frontend"

  image_name     = local.frontend_image
  container_port = { name = "http1", port = 3000 }
  ingress        = "INGRESS_TRAFFIC_ALL"

  env_vars = [
    { name = "API_URL", value = module.backend.service_url }
  ]

  vpc_network    = "projects/${var.project_id}/global/networks/${module.cloud_vpc.vpc_name}"
  vpc_subnetwork = module.cloud_vpc.subnets["${var.region}/cloud-run-subnet"]["name"]

  members = ["allUsers"]
}

module "backend" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ilcp-backend"

  image_name     = local.backend_image
  container_port = { name = "http1", port = 3001 }
  ingress        = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  env_vars = [
    { name = "DATABASE_URL", value = "postgresql://ilcp_user@${module.cloud_sql.private_ip_address}:5432/dev" },
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

  vpc_network    = "projects/${var.project_id}/global/networks/${module.cloud_vpc.vpc_name}"
  vpc_subnetwork = module.cloud_vpc.subnets["${var.region}/cloud-run-subnet"]["name"]
}

module "db_migration_job" {
  source = "./modules/cloud_run_job"

  name                  = "db-migrate"
  region                = var.region
  project_id            = var.project_id
  image                 = local.backend_image
  service_account_email = google_service_account.migration_job.email

  vpc_access = {
    network    = "projects/${var.project_id}/global/networks/${module.cloud_vpc.vpc_name}"
    subnetwork = module.cloud_vpc.subnets["${var.region}/cloud-run-subnet"]["name"]
    egress     = "ALL_TRAFFIC"
  }

  command = ["node"]
  args    = ["node_modules/typeorm/cli.js", "migration:run", "-d", "/app/services/api/dist/data-source.js"]

  env_vars = {
    DATABASE_URL = "postgresql://ilcp_user@${module.cloud_sql.private_ip_address}:5432/dev"
  }

  secret_env_vars = {
    DB_PASSWORD = {
      secret  = "DB_PASSWORD"
      version = "latest"
    }
  }

  depends_on = [
    google_secret_manager_secret_iam_member.migration_db_password
  ]
}

# Migration job service account
resource "google_service_account" "migration_job" {
  project      = var.project_id
  account_id   = "db-migration-sa"
  display_name = "DB Migration Cloud Run Job"
}

# IAM grants
resource "google_secret_manager_secret_iam_member" "migration_db_password" {
  project   = var.project_id
  secret_id = "DB_PASSWORD"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.migration_job.email}"
}
resource "google_storage_bucket_iam_member" "backend_storage_object_user" {
  bucket = module.cloud_storage.ids["dev"]
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${module.backend.service_account_email}"
}
resource "google_cloud_run_v2_service_iam_member" "authenticated_backend_access" {
  project  = var.project_id
  location = var.region
  role     = "roles/run.invoker"
  name     = module.backend.service_name
  member   = "serviceAccount:${module.frontend.service_account_email}"
}