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

resource "docker_container" "web" {
  name  = "${var.project_name}-web"
  image = docker_image.web.image_id

  ports {
    internal = 80
    external = var.external_port
  }
}
