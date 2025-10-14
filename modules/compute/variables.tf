variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for the EC2 instance."
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet for the EC2 instance."
  type        = string
}

variable "ssh_key_path" {
  description = "The file path to the public SSH key."
  type        = string
}

variable "my_ip" {
  description = "Your local public IP address for SSH access."
  type        = string
}

# Database connection details
variable "db_endpoint" {
  description = "The endpoint of the RDS database."
  type        = string
}

variable "db_name" {
  description = "The name of the database."
  type        = string
}

variable "db_username" {
  description = "The username for the database."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database."
  type        = string
  sensitive   = true
}