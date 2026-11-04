mock_provider "kubernetes" {}

variables {
  name        = "web"
  environment = "dev"
  namespace   = "dev"
  image       = "nginxdemos/hello:plain-text"
  host        = "web-dev.localtest.me"
}

run "ingress_uses_the_given_host" {
  command = plan

  assert {
    condition     = kubernetes_ingress_v1.this.spec[0].rule[0].host == "web-dev.localtest.me"
    error_message = "Ingress host should come from var.host."
  }
}

run "config_map_always_has_app_name" {
  command = plan

  assert {
    condition     = kubernetes_config_map_v1.this.data["APP_NAME"] == "web"
    error_message = "ConfigMap should always carry APP_NAME."
  }
}

run "extra_env_vars_are_merged" {
  command = plan

  variables {
    env_vars = { APP_ENV = "dev" }
  }

  assert {
    condition     = kubernetes_config_map_v1.this.data["APP_ENV"] == "dev" && kubernetes_config_map_v1.this.data["APP_NAME"] == "web"
    error_message = "Extra env vars should be merged with APP_NAME."
  }
}

run "rejects_zero_replicas" {
  command = plan

  variables {
    replicas = 0
  }

  expect_failures = [var.replicas]
}

run "rejects_bad_name" {
  command = plan

  variables {
    name = "Web_App"
  }

  expect_failures = [var.name]
}

run "rejects_bad_memory_limit" {
  command = plan

  variables {
    memory_limit = "lots"
  }

  expect_failures = [var.memory_limit]
}

run "prod_cannot_use_latest" {
  command = plan

  variables {
    environment = "prod"
    image       = "nginxdemos/hello:latest"
  }

  expect_failures = [kubernetes_deployment_v1.this]
}

run "dev_can_use_latest" {
  command = plan

  variables {
    image = "nginxdemos/hello:latest"
  }

  assert {
    condition     = kubernetes_deployment_v1.this.spec[0].template[0].spec[0].container[0].image == "nginxdemos/hello:latest"
    error_message = "Dev should accept an unpinned image."
  }
}
