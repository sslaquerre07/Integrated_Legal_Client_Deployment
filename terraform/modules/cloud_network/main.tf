module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.0"

  project_id   = var.project_id
  network_name = "cloud-run-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "cloud-run-subnet"
      subnet_ip             = "10.10.0.0/28"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Cloud Run VPC Connector Subnet"
    }
  ]
}

module "serverless_connector" {
  source  = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version = "~> 18.0"

  project_id = var.project_id
  vpc_connectors = [{
    name            = "central-serverless"
    region          = var.region
    subnet_name     = module.vpc.subnets["${var.region}/cloud-run-subnet"]["name"]
    host_project_id = var.project_id
    machine_type    = "e2-micro"
    min_instances   = 2
    max_instances   = 3
  }]
}