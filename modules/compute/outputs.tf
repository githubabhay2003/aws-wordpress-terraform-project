output "web_server_public_ip" {
  description = "The public IP address of the WordPress web server."
  value       = aws_instance.web_server.public_ip
}

output "web_security_group_id" {
  description = "The ID of the security group for the web server."
  value       = aws_security_group.web_sg.id
}