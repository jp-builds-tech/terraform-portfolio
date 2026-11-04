output "namespaces" {
  description = "Namespace name mapped to its UID."
  value       = { for k, ns in kubernetes_namespace_v1.ns : k => ns.metadata[0].uid }
}

output "traefik_status" {
  description = "Status of the Traefik Helm release."
  value       = helm_release.traefik.status
}

output "traefik_chart_version" {
  description = "Version of the Traefik chart that is installed."
  value       = helm_release.traefik.version
}

output "app_urls" {
  description = "URL for each app deployment, keyed by environment and app."
  value       = { for k, m in module.app : k => "http://${m.host}:8080" }
}
