variable "cluster_name" {
  description = "Name of the kind cluster."
  type        = string
  default     = "platform"
}

variable "worker_count" {
  description = "Number of worker nodes (1-3)."
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 3
    error_message = "worker_count must be between 1 and 3."
  }
}

variable "node_image" {
  description = "Kubernetes node image."
  type        = string
  default     = "kindest/node:v1.37.0"
}