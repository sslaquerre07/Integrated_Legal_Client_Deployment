module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.0"

  project_id   = var.project_id
  network_name = "cloud-run-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "cloud-run-subnet"
      subnet_ip             = "10.10.0.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Cloud Run Direct VPC Egress subnet"
    }
  ]
}