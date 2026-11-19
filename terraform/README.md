# Terraform infrastructure

This directory contains the Google Cloud infrastructure configuration. The
root configuration in `main.tf` composes these modules:

- **Cloud network** (`modules/cloud_network`): a shared VPC and a dedicated
  regional `/24` subnet with Private Google Access for Direct VPC Egress from
  Cloud Run. There is no Serverless VPC Access connector.
- **Cloud SQL** (`modules/cloud-sql`): a PostgreSQL 16 instance, a `dev`
  database, and the `ilcp_user` database user. The user's password comes from
  the latest version of the `DB_PASSWORD` Secret Manager secret in the selected
  project. The instance is private-IP-only and uses private services access on
  the shared VPC.
- **Cloud Storage** (`modules/storage`): a standard storage bucket with the
  `ilcp-storage-bucket` prefix and `dev` name.
- **Cloud Run** (`modules/cloud_run`): `ilcp-frontend` and `ilcp-backend`, each
  with its own service account. Both attach directly to the shared VPC using
  the regional subnet and route all egress through it (`ALL_TRAFFIC`). The
  frontend allows unauthenticated ingress; the backend allows only internal
  ingress and grants the frontend service account the Cloud Run Invoker role.

The backend receives a password-free `DATABASE_URL` containing the Cloud SQL
private IP and database name, with the `DB_PASSWORD` secret provided separately
as an environment variable. 

The current service-to-service traffic, Cloud SQL's private IP, and Cloud
Storage access through Google APIs do not require general internet egress:
the subnet provides the VPC path, Private Services Access, and Private Google
Access for those destinations. Cloud NAT is therefore not needed for the
currently configured connections. 

If either service later needs to call a public third-party API or another internet 
destination, add Cloud NAT (or another suitable VPC egress route) to provide that 
access. The backend's internal ingress and its invoker grant are independent of 
VPC egress. Frontend-to-backend calls must be made server-side through the 
frontend's VPC connection and include a Google-signed ID token for the frontend 
service account; browser requests directly to the backend URL do not use the 
frontend's VPC connection and cannot reach the backend's internal-only ingress.
