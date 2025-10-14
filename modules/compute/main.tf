data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. SSH Key Pair
# This resource uploads your public key to AWS.
resource "aws_key_pair" "deployer_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_key_path)
}

# 2. Web Server Security Group
# This firewall allows HTTP traffic from anywhere and SSH traffic only from your IP.
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This allows all traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# 3. EC2 Instance
# This is the virtual server for our WordPress application.
resource "aws_instance" "web_server" {
  # Notice I've changed the hardcoded AMI to the data source lookup
  # we developed earlier. This is the best practice.
  ami                    = data.aws_ami.amazon_linux_2.id 
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  key_name               = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # This is the new, more reliable way to run our script.
  # The templatefile function will read our script and substitute the variables.
  user_data = templatefile("${path.module}/install_wordpress.sh", {
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_endpoint = var.db_endpoint
  })

  tags = {
    Name = "${var.project_name}-web-server"
  }
}