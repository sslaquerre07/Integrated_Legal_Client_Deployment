output "vpc_name" {
  value       = module.vpc.network_name
  description = "VPC created for the direct VPC connection"
}

output "network_self_link" {
  value       = module.vpc.network_self_link
  description = "Self-link of the VPC network"
}

output "subnets" {
  value       = module.vpc.subnets
  description = "VPC Subnets"
}