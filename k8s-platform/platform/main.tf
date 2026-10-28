locals {
  all_namespaces = setunion(["traefik"], var.namespaces)

  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

resource "kubernetes_namespace_v1" "ns" {
  for_each = local.all_namespaces

  metadata {
    name   = each.key
    labels = local.common_labels
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = var.traefik_chart_version
  namespace  = kubernetes_namespace_v1.ns["traefik"].metadata[0].name

  values = [file("${path.module}/values/traefik.yaml")]

  wait    = true
  timeout = 300
}
