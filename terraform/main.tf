terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "devops-capstone-tf-state-509521484446"
    key          = "devops-capstone/terraform.tfstate"
    region       = "af-south-1"
    encrypt      = true
    use_lockfile = true
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "af-south-1"
}

# --------------------------
# VPC
# --------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-capstone-vpc"
  }
}

# --------------------------
# Public Subnet
# --------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "af-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-capstone-public-subnet"
  }
}

# --------------------------
# Private Subnet
# --------------------------

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "af-south-1b"

  tags = {
    Name = "devops-capstone-private-subnet"
  }
}

# --------------------------
# Internet Gateway
# --------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-capstone-igw"
  }
}

# --------------------------
# Public Route Table
# --------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "devops-capstone-public-route-table"
  }
}

# --------------------------
# Public Route Table Association
# --------------------------

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --------------------------
# Security Group
# --------------------------

resource "aws_security_group" "web_sg" {
  name        = "devops-capstone-web-sg"
  description = "Allow web traffic to EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-capstone-web-sg"
  }
}

# --------------------------
# Latest Amazon Linux AMI
# --------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# --------------------------
# EC2 Instance
# --------------------------

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # Attach IAM role for SSM and ECR access
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable docker
    systemctl start docker
  EOF

  tags = {
    Name = "devops-capstone-web"
  }
}