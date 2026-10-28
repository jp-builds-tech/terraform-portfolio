variable "namespaces" {
  description = "Application namespaces to create."
  type        = set(string)
  default     = ["dev", "prod"]

  validation {
    condition     = alltrue([for n in var.namespaces : can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", n))])
    error_message = "Namespace names must be lowercase letters, numbers, and dashes."
  }

  validation {
    condition     = !contains(var.namespaces, "traefik")
    error_message = "The name traefik is reserved for the ingress controller."
  }
}

variable "traefik_chart_version" {
  description = "Pinned Traefik Helm chart version."
  type        = string
  default     = "42.1.3"
}
