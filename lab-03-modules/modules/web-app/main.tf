terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "web" {
  name         = "nginx:${var.nginx_tag}"
  keep_locally = true
}

resource "docker_container" "web" {
  for_each = var.containers

  name  = "${var.env}-${each.key}"
  image = docker_image.web.image_id

  ports {
    internal = 80
    external = each.value
  }
}