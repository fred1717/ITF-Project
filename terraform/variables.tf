# Input variable definitions for Terraform project


# VPC ID where all resources will be deployed
variable "vpc_id" {
  description = "The ID of the VPC where endpoints and resources will be created"
  type        = string
}
