output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by subnet name."
  value       = { for k, s in aws_subnet.this : k => s.id }
}

output "security_group_id" {
  description = "ID of the web security group."
  value       = aws_security_group.web.id
}
