# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Data source to get the public IP of the machine running Terraform
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

# ------------------- MODULE CALLS -------------------

module "network" {
  source       = "./modules/network"
  project_name = "wordpress"
}

module "database" {
  source = "./modules/database"

  project_name       = "wordpress"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module "compute" {
  source = "./modules/compute"

  project_name     = "wordpress"
  vpc_id           = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_id
  ssh_key_path     = var.ssh_key_path
  my_ip            = chomp(data.http.my_ip.response_body) # Use the automatically detected IP

  # Pass database details to the compute module for wp-config.php
  db_endpoint = module.database.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

# ------------------- VARIABLES -------------------

variable "db_name" {
  description = "Name for the WordPress database"
  type        = string
}

variable "db_username" {
  description = "Username for the WordPress database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the WordPress database"
  type        = string
  sensitive   = true
}

variable "ssh_key_path" {
  description = "The file path to the public SSH key to be used for the EC2 instance."
  type        = string
}

# ------------------- SECURITY INTEGRATION -------------------

# This resource creates the critical link between the web server and the database.
resource "aws_security_group_rule" "allow_db_connection" {
  type                     = "ingress"
  description              = "Allow web server to connect to the database"
  from_port                = 3306 # MySQL port
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.database.db_security_group_id # The DB's firewall
  source_security_group_id = module.compute.web_security_group_id  # The Web Server's firewall
}

# ------------------- OUTPUTS -------------------

output "wordpress_url" {
  description = "The public URL of the WordPress installation."
  value       = "http://${module.compute.web_server_public_ip}"
}