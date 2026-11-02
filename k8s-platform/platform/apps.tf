locals {
  deployments = {
    for pair in setproduct(keys(var.environments), keys(var.apps)) :
    "${pair[0]}-${pair[1]}" => {
      env = pair[0]
      app = pair[1]
    }
  }
}

module "app" {
  source   = "../modules/app"
  for_each = local.deployments

  name         = each.value.app
  environment  = each.value.env
  namespace    = kubernetes_namespace_v1.ns[each.value.env].metadata[0].name
  image        = var.apps[each.value.app].image
  port         = var.apps[each.value.app].port
  replicas     = var.environments[each.value.env].replicas
  memory_limit = var.environments[each.value.env].memory_limit
  host         = "${each.value.app}-${each.value.env}.localtest.me"
  env_vars     = { APP_ENV = each.value.env }

  depends_on = [helm_release.traefik]
}
