variable "name" {
  description = "Name prefix for the resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block of the VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid CIDR range."
  }
}

variable "subnets" {
  description = "Subnets to create, keyed by name. netnum picks the /24 inside the VPC."
  type = map(object({
    az     = string
    public = bool
    netnum = number
  }))
}

variable "ingress_ports" {
  description = "TCP ports allowed into the web security group."
  type        = set(number)
  default     = [80, 443]

  validation {
    condition     = alltrue([for p in var.ingress_ports : p >= 1 && p <= 65535])
    error_message = "Ports must be between 1 and 65535."
  }
}
