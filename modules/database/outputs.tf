output "db_endpoint" {
  description = "The endpoint address of the RDS instance."
  value       = aws_db_instance.db_instance.endpoint
}

output "db_security_group_id" {
  description = "The ID of the security group for the RDS instance."
  value       = aws_security_group.db_sg.id
}