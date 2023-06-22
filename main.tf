# Initialize Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Creating a VPC
resource "aws_vpc" "project-2-finance-me-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "project-2-finance-me-ig" {
  vpc_id = aws_vpc.project-2-finance-me-vpc.id

  tags = {
    Name = "Internet-gateway-1"
  }
}

# Setting up the route table
resource "aws_route_table" "project-2-finance-me-rt" {
  vpc_id = aws_vpc.project-2-finance-me-vpc.id

  route {
    # Pointing to the internet
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-2-finance-me-ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.project-2-finance-me-ig.id
  }

  tags = {
    Name = "rt1"
  }
}

# Setting up the subnet
resource "aws_subnet" "project-2-finance-me-subnet" {
  vpc_id            = aws_vpc.project-2-finance-me-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet1"
  }
}

# Associating the subnet with the route table
resource "aws_route_table_association" "project-2-finance-me-rt-sub-assoc" {
  subnet_id      = aws_subnet.project-2-finance-me-subnet.id
  route_table_id = aws_route_table.project-2-finance-me-rt.id
}

# Creating a Security Group
resource "aws_security_group" "project-2-finance-me" {
  name        = "project-2-finance-me"
  description = "Enable web traffic for the project"
  vpc_id      = aws_vpc.project-2-finance-me-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port 8080 inbound"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow port 65000 inbound"
    from_port   = 0
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-2-finance-me"
  }
}

# Creating a new network interface
resource "aws_network_interface" "project-2-finance-me-ni" {
  subnet_id       = aws_subnet.project-2-finance-me-subnet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.project-2-finance-me.id]
}

# Attaching an elastic IP to the network interface
resource "aws_eip" "project-2-finance-me-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.project-2-finance-me-ni.id
  associate_with_private_ip = "10.0.1.10"
}

# Creating an Ubuntu EC2 instance
resource "aws_instance" "Prod-Server" {
  ami               = "ami-0261755bbcb8c4a84"
  instance_type     = "t2.small"
  availability_zone = "us-east-1a"
  key_name          = "star-jenkins"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.project-2-finance-me-ni.id
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt install docker.io -y
    sudo systemctl enable docker
    sudo docker run -itd -p 8085:8081 subham742/finance-me:latest
    sudo docker start \$(docker ps -aq)
  EOF

  tags = {
    Name = "Prod-Server"
  }
}


