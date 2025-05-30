# Data source to dynamically fetch the subnet ID by tag and AZ
data "aws_subnet" "app_subnet" {
  filter {
    name   = "tag:Name"
    values = ["ITF_PrivateSub_AZ1"]
  }

  filter {
    name   = "availabilityZone"
    values = ["us-east-1a"]
  }
}


# Data source to dynamically fetch the security group ID by group name
data "aws_security_group" "app_sg" {
  filter {
    name   = "group-name"
    values = ["ITF_SG_DR-WebAccess"]
  }

  vpc_id = var.vpc_id
}



resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    data.aws_subnet.private_az1.id,  # PrivateSub_AZ1
    data.aws_subnet.private_az2.id   # PrivateSub_AZ2
  ]

  security_group_ids = [
    data.aws_security_group.app_sg.id  # ITF_SG_DR-WebAccess
  ]

  tags = {
    Name = "VPCE-SSMMessages"
  }
}

}



# VPC Interface Endpoint for AWS Systems Manager (SSM)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    data.aws_subnet.private_az1.id,  # PrivateSub_AZ1
    data.aws_subnet.private_az2.id   # PrivateSub_AZ2
  ]

  security_group_ids = [
    data.aws_security_group.app_sg.id  # ITF_SG_DR-WebAccess
  ]

  tags = {
    Name = "VPCE-SSM"
  }
}


# VPC Interface Endpoint for EC2 Messages
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    data.aws_subnet.private_az1.id,  # PrivateSub_AZ1
    data.aws_subnet.private_az2.id   # PrivateSub_AZ2
  ]

  security_group_ids = [
    data.aws_security_group.app_sg.id  # ITF_SG_DR-WebAccess
  ]

  tags = {
    Name = "VPCE-EC2Messages"
  }
}


# VPC Interface Endpoint for SSM Messages (used by Session Manager)
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    data.aws_subnet.private_az1.id,  # PrivateSub_AZ1
    data.aws_subnet.private_az2.id   # PrivateSub_AZ2
  ]

  security_group_ids = [
    data.aws_security_group.app_sg.id  # ITF_SG_DR-WebAccess
  ]

  tags = {
    Name = "VPCE-SSMMessages"
  }
}

}
