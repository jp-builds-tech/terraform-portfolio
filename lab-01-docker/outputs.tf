output "url" {
  description = "Where to reach the web server."
  value       = "http://localhost:${var.external_port}"
}

output "container_id" {
  description = "Docker container ID (find this in terraform.tfstate)."
  value       = docker_container.web.id
}
