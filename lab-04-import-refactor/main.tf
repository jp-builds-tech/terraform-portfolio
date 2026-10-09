terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "lab" {
  name = "labnet"
}

moved {
  from = docker_network.labnet
  to   = docker_network.lab
}