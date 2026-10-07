output "url" {
  description = "Where to reach the web server."
  value       = { for name, c in docker_container.web : name => "http://localhost:${c.ports[0].external}" }
}

output "container_id" {
  description = "Docker container ID (find this in terraform.tfstate)."
  value       = docker_container.web[*].id
}
