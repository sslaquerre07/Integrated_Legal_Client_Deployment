# Terraform infrastructure

This directory contains the Google Cloud infrastructure configuration. The root
configuration in `main.tf` composes three modules:

- **Cloud SQL** (`modules/cloud-sql`): a PostgreSQL 16 instance, a `dev`
  database, and the `ilcp_user` database user. The user's password comes from
  the latest version of the `DB_PASSWORD` Secret Manager secret in the selected
  project.
- **Cloud Storage** (`modules/storage`): a standard storage bucket with the
  `ilcp-storage-bucket` prefix and `dev` name.
- **Cloud Run** (`modules/cloud_run`): `ilcp-frontend` and `ilcp-backend`, each
  with its own service account. Both currently use Google's sample hello image
  on port 8080. The frontend grants `allUsers` the invoker role, so it allows
  unauthenticated requests. The backend has no public invoker binding; its
  ingress setting allows external routing, but callers still need permission.

The backend service account is granted Cloud SQL Client access. Its Cloud Run
service is configured to connect to the Cloud SQL instance and receives the
`DB_PASSWORD` secret as an environment variable. The frontend's `API_URL` is
currently an example URL (`https://api.example.com`), not the deployed backend
URL.
