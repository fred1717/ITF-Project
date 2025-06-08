# Provider Configuration
provider "aws" {
  region = "us-east-1"  # Change as needed
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ec2_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ec2_ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Example security group (outbound HTTPS)
resource "aws_security_group" "ssm_allow_https" {
  name        = "allow-https-egress"
  description = "Allow HTTPS outbound for SSM"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }
}

# Modify the EC2 instance block
resource "aws_instance" "AppTier_Private-ITF_AZ1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
    subnet_id = data.aws_subnet.private_az1.id 
    vpc_security_group_ids = [
        "data.aws_security_group.app_sg.id",
        "aws_security_group.ssm_allow_https.id" 
    ]
  iam_instance_profile   = data.aws_iam_instance_profile.existing_profile.name

  user_data = templatefile("${path.module}/scripts/user_data.sh", {})

  tags = {
    Name = "AppTier_Private-ITF_AZ1"
  }
}

data "aws_iam_instance_profile" "existing_profile" {
  name = var.instance_profile_name
}
