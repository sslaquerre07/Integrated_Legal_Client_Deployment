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

module "frontend" {
  source       = "./modules/cloud_run"
  project_id   = var.project_id
  region       = var.region
  service_name = "ilcp-frontend"

  image_name     = "us-west1-docker.pkg.dev/integrated-legal-client-portal/application-images-fe-and-be/frontend:ff4975fd950fe9842f31242a6ad9cb8f0d1c5e8e"
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

  image_name     = "us-west1-docker.pkg.dev/integrated-legal-client-portal/application-images-fe-and-be/backend:4e4b9805926beda462040422be8c9d6b33b77555"
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

resource "google_cloud_run_v2_service_iam_member" "authenticated_backend_access" {
  project  = var.project_id
  location = var.region
  role     = "roles/run.invoker"
  name     = module.backend.service_name

  member = "serviceAccount:${module.frontend.service_account_email}"
}