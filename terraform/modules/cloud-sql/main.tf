# Instance for PostgreSQL database
resource "google_sql_database_instance" "postgresql_instance" {
  name             = "ilcp-postgresql-instance"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier = "db-perf-optimized-N-2"

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
  password = var.db_password
}