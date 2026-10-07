variable "project_name" {
  description = "Prefix for resource names."
  type        = string
  default     = "lab01"
}

variable "nginx_tag" {
  description = "nginx image tag to run."
  type        = string
  default     = "1.27-alpine"
}

variable "containers" {
  description = "Map of container name to host port."
  type        = map(number)
  default = {
    "web-a" = 8081
    "web-b" = 8082
    "web-c" = 8083
  }

  validation {
    condition = alltrue ([ for port in values(var.containers) : port >= 8000 && port <= 8999 ])
    error_message = "external_port must be between 8000 and 8999."
  }
}