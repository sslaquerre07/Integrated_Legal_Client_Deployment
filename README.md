# Infrastructure Repository

This repository contains the infrastructure configurations, Terraform scripts, and deployment setups for the application.

## Prerequisites & Getting Started

To ensure a consistent development environment across all machines, this project uses **VS Code Dev Containers**.

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

---

## Available Tools inside Container

- **Docker-in-Docker:** Run and build Docker images directly inside the workspace container.
- **Terraform:** Provision and manage infrastructure states.
- **GitHub CLI (`gh`):** Manage pull requests, issues, and workflows.
- **Google Cloud SDK (`gcloud`):** Deploy and configure GCP services.