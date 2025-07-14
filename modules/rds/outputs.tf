output "db_endpoint" {
  description = "Read replica database endpoint"
  value       = aws_db_instance.replica.endpoint
}

output "db_instance_id" {
  description = "RDS replica instance identifier"
  value       = aws_db_instance.replica.id
}
