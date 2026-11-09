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

variable "state_bucket_name" {
  description = "Name of the bucket that stores Terraform state."
  type        = string
  default     = "tf-state-lab"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB lock table."
  type        = string
  default     = "tf-locks"
}
