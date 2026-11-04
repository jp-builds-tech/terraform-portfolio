locals {
  labels = {
    app                            = var.name
    environment                    = var.environment
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

resource "kubernetes_config_map_v1" "this" {
  metadata {
    name      = "${var.name}-config"
    namespace = var.namespace
    labels    = local.labels
  }

  data = merge({ APP_NAME = var.name }, var.env_vars)
}

resource "kubernetes_deployment_v1" "this" {
  #checkov:skip=CKV_K8S_43:Image tag is pinned; digest pinning needs a lookup process that is overkill for this lab
  #checkov:skip=CKV_K8S_15:Always would re-pull on every pod start and hit Docker Hub rate limits in this local lab
  #checkov:skip=CKV_K8S_22:nginx needs writable cache and PID directories, read-only root would need emptyDir mounts, left as a follow-up
  #checkov:skip=CKV_K8S_37:This nginx image starts as root and needs capabilities to bind port 80, dropping ALL would stop it from starting

  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        automount_service_account_token = false

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name  = var.name
          image = var.image

          port {
            container_port = var.port
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.this.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "25m"
              memory = "16Mi"
            }
            limits = {
              cpu    = "200m"
              memory = var.memory_limit
            }
          }

          security_context {
            allow_privilege_escalation = false

            capabilities {
              drop = ["NET_RAW"]
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.port
            }
            initial_delay_seconds = 2
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.port
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.environment == "prod" && endswith(var.image, ":latest"))
      error_message = "Production deployments must pin an image tag, not :latest."
    }
  }
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    selector = {
      app = var.name
    }

    port {
      port        = var.port
      target_port = var.port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = var.host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.this.metadata[0].name
              port {
                number = var.port
              }
            }
          }
        }
      }
    }
  }
}
