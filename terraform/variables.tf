# Define input variables 
variable "vpc_id" {
    description = "The ID of the VPC where endpoints will be created"
    type        = string
}


variable "private_subnet_ids" {
    description = "List of private subnet IDs across AZs" 
    type        = list(string)
} 


variable "security_group_id" {
    description = "Security group to attach to the endpoints" 
    type        = string
}
