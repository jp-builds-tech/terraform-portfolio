variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "endpoint" {
  description = "API endpoint of the local AWS emulator."
  type        = string
  default     = "http://localhost:5000"
}

variable "ingress_ports" {
  description = "TCP ports allowed into the web security group."
  type        = set(number)
  default     = [80, 443]
}
