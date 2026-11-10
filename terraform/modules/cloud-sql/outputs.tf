output "postgresql_connection_name" {
  description = "The connection name of the PostgreSQL instance"
  value       = google_sql_database_instance.postgresql_instance.connection_name
}