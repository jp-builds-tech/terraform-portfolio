variable "env" {
  description = "Environment name."
  type        = string
}

variable "project_name" {
  description = "Prefix for resource names."
  type        = string
  default     = "lab01"
}

variable "nginx_tag" {
  description = "Nginx image tag to run."
  type        = string
  default     = "latest"
}

variable "containers" {
  description = "Map of container name to host port."
  type        = map(number)

  validation {
    condition = alltrue([
      for port in values(var.containers) :
      port >= 8000 && port <= 8999
    ])

    error_message = "External ports must be between 8000 and 8999."
  }
}