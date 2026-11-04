output "host" {
  description = "Hostname the app's Ingress answers to."
  value       = var.host
}

output "service_name" {
  description = "Name of the app's Service."
  value       = kubernetes_service_v1.this.metadata[0].name
}
