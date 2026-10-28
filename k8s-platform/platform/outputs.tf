output "namespaces" {
  value = { for k, ns in kubernetes_namespace_v1.ns : k => ns.metadata[0].uid }
}

output "traefik_status" {
  value = helm_release.traefik.status
}

output "traefik_chart_version" {
  value = helm_release.traefik.version
}
