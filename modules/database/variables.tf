variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the database will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "db_username" {
  description = "The master username for the database."
  type        = string
  sensitive   = true # Mark this as sensitive so Terraform doesn't show it in logs.
}

variable "db_password" {
  description = "The master password for the database."
  type        = string
  sensitive   = true # Mark this as sensitive.
}