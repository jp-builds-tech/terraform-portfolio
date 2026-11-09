output "state_bucket" {
  description = "Name of the state bucket."
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "Name of the lock table."
  value       = aws_dynamodb_table.locks.name
}
