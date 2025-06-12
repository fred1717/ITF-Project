variable "ami_id" {
    description = "The AMI ID for the EC2 instance" 
    type = string
} 

variable "instance_type" {
    description = "The type of EC2 instance to launch" 
    type = string
    default = "t3.micro"
} 

variable "public_subnet_name_az1" {
  description = "Name tag for the public subnet in AZ1"
  type        = string
}

variable "public_subnet_name_az2" {
  description = "Name tag for the public subnet in AZ2"
  type        = string
}

variable "private_subnet_name_az1" {
  description = "Name tag of private subnet in AZ1"
  type        = string
}

variable "private_subnet_name_az2" {
  description = "Name tag of private subnet in AZ2"
  type        = string
}

variable "app_sg_name" {
  description = "Name tag of the security group for the EC2 instance"
  type        = string
}

variable "vpc_id" {
    description = "VPC ID where the EC2 instance and security group will be deployed" 
    type = string
}

variable "instance_profile_name" {
  description = "Name of the existing IAM instance profile used for SSM access"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  description = "Prefix to use for named AWS resources"
  type        = string
}
