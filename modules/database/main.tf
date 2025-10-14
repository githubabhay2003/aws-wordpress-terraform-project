# 1. DB Subnet Group
# RDS needs to know which subnets within the VPC it can use. We specify our private subnets here.
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# 2. Database Security Group
# This acts as a virtual firewall for our database.
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow inbound traffic from the application layer"
  vpc_id      = var.vpc_id

  # We will add a specific ingress rule later to allow the EC2 instance to connect.
  # For now, we leave it empty. By default, all inbound traffic is denied.

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# 3. RDS MySQL Instance
# This is the managed database instance itself.
resource "aws_db_instance" "db_instance" {
  identifier           = "${var.project_name}-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Free-tier eligible
  allocated_storage    = 20
  storage_type         = "gp2"

  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible  = false # CRITICAL: Ensures the database is not exposed to the internet.
  skip_final_snapshot  = true  # IMPORTANT: Set to true for dev/test to allow easy destruction.
                               # In production, this should be false.
}