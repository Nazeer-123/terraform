# --- Provider Configuration ---
provider "aws" {
  region = "us-east-1" # Use your desired region
}

# --- Security Group (Allow SSH Access) ---
resource "aws_security_group" "docker_host_sg" {
  name        = "docker-host-sg"
  description = "Allow SSH access to the Docker host"
  vpc_id      = var.vpc_id # Uses the value from terraform.tfvars

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins (Port 8080)
  ingress { 
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # SonarQube (Port 9000)
  ingress { 
    from_port = 9000
    to_port = 9000
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
  # Nexus (Port 8081)
  ingress { 
    from_port = 8081
    to_port = 8081
     protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
  }
}

# --- EC2 Instance: The Docker Host ---
resource "aws_instance" "doc_ker_host" {
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI for us-east-1
  instance_type = "t2.medium"
  key_name      = var.key_name            # Uses the value from terraform.tfvars
  subnet_id     = var.subnet_id           # Uses the value from terraform.tfvars
  vpc_security_group_ids = [aws_security_group.docker_host_sg.id]

  # Inject the Docker installation script
  user_data = file("${path.module}/install_docker.sh")

  tags = {
    Name = "Docker-Terraform-Host"
  }
}

# --- Output: Get the IP to connect to the new host ---
output "docker_host_public_ip" {
  description = "The public IP address of the Docker host"
  value       = aws_instance.doc_ker_host.public_ip
}