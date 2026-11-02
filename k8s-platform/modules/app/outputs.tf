output "host" {
  value = var.host
}

output "service_name" {
  value = kubernetes_service_v1.this.metadata[0].name
}
