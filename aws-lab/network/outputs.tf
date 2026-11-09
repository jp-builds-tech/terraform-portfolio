output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by subnet name."
  value       = module.vpc.subnet_ids
}

output "security_group_id" {
  description = "ID of the web security group."
  value       = module.vpc.security_group_id
}
