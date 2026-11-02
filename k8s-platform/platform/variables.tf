variable "environments" {
  description = "Environments to create. The key is also the namespace name."
  type = map(object({
    replicas     = number
    memory_limit = string
  }))
  default = {
    dev  = { replicas = 1, memory_limit = "64Mi" }
    prod = { replicas = 2, memory_limit = "128Mi" }
  }

  validation {
    condition     = alltrue([for k in keys(var.environments) : can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", k))])
    error_message = "Environment names must be lowercase letters, numbers, and dashes."
  }

  validation {
    condition     = !contains(keys(var.environments), "traefik")
    error_message = "The name traefik is reserved for the ingress controller."
  }
}

variable "apps" {
  description = "Apps to deploy into every environment."
  type = map(object({
    image = string
    port  = optional(number, 80)
  }))
  default = {
    web = { image = "nginxdemos/hello:plain-text" }
    api = { image = "nginxdemos/hello:plain-text" }
  }
}

variable "traefik_chart_version" {
  description = "Pinned Traefik Helm chart version."
  type        = string
  default     = "42.1.3"
}
