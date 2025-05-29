# Define outputs for visibility after apply


output "ssm_endpoint_id" {
  description = "ID of the VPC Endpoint for SSM"
  value       = aws_vpc_endpoint.ssm.id
}



output "ec2messages_endpoint_id" {
  description = "ID of the VPC Endpoint for EC2 Messages"
  value       = aws_vpc_endpoint.ec2messages.id
}



output "ssmmessages_endpoint_id" {
  description = "ID of the VPC Endpoint for SSM Messages"
  value       = aws_vpc_endpoint.ssmmessages.id
}

