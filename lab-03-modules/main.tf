terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

module "dev" {
  source    = "./modules/web-app"
  env       = "dev"
  nginx_tag = "latest"

  containers = {
    "web-a" = 8081
    "web-b" = 8082
  }
}

module "prod" {
  source    = "./modules/web-app"
  env       = "prod"
  nginx_tag = "latest"

  containers = {
    "web-a" = 8091
    "web-b" = 8092
  }
}