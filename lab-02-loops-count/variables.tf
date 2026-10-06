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

variable "external_port" {
  description = "Host port mapped to the container's port 80."
  type        = number
  default     = 8080

  validation {
    condition     = var.external_port >= 8000 && var.external_port <= 8999
    error_message = "external_port must be between 8000 and 8999."
  }
}
