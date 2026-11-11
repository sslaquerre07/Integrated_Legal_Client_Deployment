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
  with its own service account. Both currently a sample image (eventually will be ours)
  on designated ports. The frontend grants `allUsers` the invoker role, so it allows
  unauthenticated requests. The backend allows calls from the frontend but nowhere else,
  later we will configure the VPC.

The backend service account is granted Cloud SQL Client access. Its Cloud Run
service is configured to connect to the Cloud SQL instance and receives the
`DB_PASSWORD` secret as an environment variable. The frontend's `API_URL` is
the url of the deployed backend service (this will also change)
