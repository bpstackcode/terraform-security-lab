terraform {
  backend "s3" {
    bucket         = "bpstackcode-terraform-state"
    key            = "terraform-security-lab/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "security_lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "security-lab-vpc"
    Environment = "lab"
    Project     = "terraform-security-lab"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.security_lab_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "security-lab-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.security_lab_vpc.id

  tags = {
    Name = "security-lab-igw"
  }
}

resource "aws_security_group" "lab_sg" {
  name        = "security-lab-sg"
  description = "Least privilege security group"
  vpc_id      = aws_vpc.security_lab_vpc.id

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

  tags = {
    Name = "security-lab-sg"
  }
}
