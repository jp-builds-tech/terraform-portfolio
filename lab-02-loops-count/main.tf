terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "web" {
  name         = "nginx:${var.nginx_tag}"
  keep_locally = true
}

locals {
  names = ["web-a", "web-b", "web-c"]
}

resource "docker_container" "web" {
  count = length(local.names)
  name  = local.names[count.index]
  image = docker_image.web.image_id

  ports {
    internal = 80
    external = 8081 + count.index
  }
}
