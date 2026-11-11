# Infrastructure Repository

This repository contains the infrastructure configurations, Terraform scripts, and deployment setups for the application.

## Prerequisites & Getting Started

To ensure a consistent development environment across all machines, this project uses **VS Code Dev Containers**

### 1. Setting Up the Dev Container

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or ensure your Docker engine is running).
2. Install [Visual Studio Code](https://code.visualstudio.com/).
3. Install the **Dev Containers** extension in VS Code (`ms-vscode-remote.remote-containers`).
4. Open this repository in VS Code.
5. When prompted in the bottom-right corner, click **Reopen in Container** (or open the Command Palette with `Ctrl+Shift+P` / `Cmd+Shift+P` and select `Dev Containers: Reopen in Container`).

---

## Google Cloud CLI Authentication

Once your Dev Container has built and opened, you must authenticate the Google Cloud (`gcloud`) CLI to interact with project resources locally.

Run the following commands in your container terminal:

```bash
# Sign in to the Google Cloud CLI and select a project
gcloud init

# Set up Application Default Credentials for local applications and client libraries
gcloud auth application-default login
```

## Terraform

Terraform is installed in the dev container. To configure it, create
`terraform/terraform.tfvars` with the Google Cloud project ID you want to use:

```hcl
project_id = "your-google-cloud-project-id"
```

That file is gitignored, so provide your own local copy. The region defaults to
`us-west1`; you can override it by adding `region = "your-region"` to the same
file. Ensure your Google credentials can create the configured resources and
read the `DB_PASSWORD` Secret Manager secret in that project.

Then initialize, review, and apply the configuration:

```sh
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

The current configuration creates Cloud Run frontend/backend services, a
Cloud SQL PostgreSQL instance and database, and a Cloud Storage bucket. The
frontend currently permits unauthenticated access; both services still use
sample images. See the [Terraform README](terraform/README.md)for resource 
details, prerequisites, and state/security notes.

---

## Available Tools inside Container

- **Docker-in-Docker:** Run and build Docker images directly inside the workspace container.
- **Terraform:** Provision and manage infrastructure states.
- **GitHub CLI (`gh`):** Manage pull requests, issues, and workflows.
- **Google Cloud SDK (`gcloud`):** Deploy and configure GCP services.