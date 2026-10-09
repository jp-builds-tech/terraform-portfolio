output "urls" {
  description = "URLs of the web containers"

  value = {
    for name, container in docker_container.web :
    name => "http://localhost:${container.ports[0].external}"
  }
}