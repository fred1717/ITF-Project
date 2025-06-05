variable "ami_id" {
    description = "The AMI ID for the EC2 instance" 
    type = string
} 

variable "instance_type" {
    description = "The type of EC2 instance to launch" 
    type = string
    default = "t3.micro"
} 

variable "private_subnet_id_az1" {
    description = "Subnet ID for launching the EC2 instance in AZ1" 
    type = string
} 

variable "vpc_id" {
    description = "VPC ID where the EC2 instance and security group will be deployed" 
    type = string
}

