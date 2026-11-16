# Read the password from Secret Manager for the Cloud SQL user.
data "google_secret_manager_secret_version" "db_password" {
  project = var.project_id
  secret  = "DB_PASSWORD"
  version = "latest"
}

# Create a private IP range for the Cloud SQL instance to use.
resource "google_compute_global_address" "private_ip_range" {
  name          = "ilcp-cloud-sql-private-ip-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network_self_link
}
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

# Instance for PostgreSQL database
resource "google_sql_database_instance" "postgresql_instance" {
  name             = "ilcp-postgresql-instance"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    edition = "ENTERPRISE"
    tier    = "db-f1-micro"

    # Keep single-zone (ZONAL) to avoid doubling costs
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network_self_link
    }
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

# Creating a dev database in the PostgreSQL instance
resource "google_sql_database" "dev_database" {
  name     = "dev"
  instance = google_sql_database_instance.postgresql_instance.name
}

# Creating a user for the databases
resource "google_sql_user" "db_user" {
  name     = "ilcp_user"
  instance = google_sql_database_instance.postgresql_instance.name
  password = data.google_secret_manager_secret_version.db_password.secret_data
}