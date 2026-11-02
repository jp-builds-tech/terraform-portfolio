variable "name" {
  description = "App name. Also used for the Deployment, Service, and Ingress."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be lowercase letters, numbers, and dashes."
  }
}

variable "environment" {
  description = "Environment name, such as dev or prod."
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy into."
  type        = string
}

variable "image" {
  description = "Container image including tag."
  type        = string
}

variable "port" {
  description = "Container port."
  type        = number
  default     = 80
}

variable "replicas" {
  description = "Number of pods (1-3)."
  type        = number
  default     = 1

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 3
    error_message = "replicas must be between 1 and 3."
  }
}

variable "memory_limit" {
  description = "Memory limit, such as 64Mi or 1Gi."
  type        = string
  default     = "64Mi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.memory_limit))
    error_message = "memory_limit must look like 64Mi or 1Gi."
  }
}

variable "host" {
  description = "Hostname the Ingress answers to."
  type        = string
}

variable "env_vars" {
  description = "Extra environment variables for the container."
  type        = map(string)
  default     = {}
}
