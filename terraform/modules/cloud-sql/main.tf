# Read the password from Secret Manager for the Cloud SQL user.
data "google_secret_manager_secret_version" "db_password" {
  project = var.project_id
  secret  = "DB_PASSWORD"
  version = "latest"
}

# Instance for PostgreSQL database
resource "google_sql_database_instance" "postgresql_instance" {
  name             = "ilcp-postgresql-instance"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    edition = "ENTERPRISE"
    tier    = "db-g1-small"

    # Keep single-zone (ZONAL) to avoid doubling costs
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled = true
    }
  }
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