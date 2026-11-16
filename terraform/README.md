# Terraform infrastructure

This directory contains the Google Cloud infrastructure configuration. The
root configuration in `main.tf` composes these modules:

- **Cloud network** (`modules/cloud_network`): a shared VPC, a dedicated
  `/28` connector subnet with Private Google Access, and a regional Serverless
  VPC Access connector used by both Cloud Run services.
- **Cloud SQL** (`modules/cloud-sql`): a PostgreSQL 16 instance, a `dev`
  database, and the `ilcp_user` database user. The user's password comes from
  the latest version of the `DB_PASSWORD` Secret Manager secret in the selected
  project. The instance is private-IP-only and uses private services access on
  the shared VPC.
- **Cloud Storage** (`modules/storage`): a standard storage bucket with the
  `ilcp-storage-bucket` prefix and `dev` name.
- **Cloud Run** (`modules/cloud_run`): `ilcp-frontend` and `ilcp-backend`, each
  with its own service account. Both use the shared VPC connector with
  `all-traffic` egress. The frontend allows unauthenticated ingress; the
  backend allows only internal ingress and grants the frontend service account
  the Cloud Run Invoker role.

The backend receives the Cloud SQL private IP as `DB_HOST` and the
`DB_PASSWORD` secret as an environment variable. Storage API calls from the
backend use the VPC connector and Private Google Access. Calls from the
frontend to the backend must be made server-side through the VPC connector and
include a Google-signed ID token for the frontend service account; browser
requests directly to the backend URL do not traverse the frontend's VPC
connector and cannot reach the backend's internal-only ingress.
