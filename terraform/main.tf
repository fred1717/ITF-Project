# Data source to dynamically fetch the subnet ID by tag and AZ  
data "aws_subnet" "app_subnet" {
    filter {
        name = "tag:Name" 
        values = [ "ITF_PrivateSub_AZ1" ]
    }

    filter {
        name = "availabilityZone" 
        values = [ "us-east-1a" ]
    }
} 

# Data source to dynamically fetch the security group ID by group name  
data "aws_security_group" "app_sg" {
    filter {
        name = "group-name" 
        values = [ "ITF_SG_DR-WebAccess" ]
    }
    vpc_id = var.vpc_id
} 

# VPC Endpoints for SSM 
resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id = var.vpc_id 
    service_name = "com.amazonaws.us-east-1.ssmmessages"
    vpc_endpoint_type = "Interface" 
    subnet_ids = [
        data.aws_subnet.app_subnet.id,                      # PrivateSub_AZ1
        data.aws_subnet.private_az2.id                      # PrivateSub_AZ2
    ]

    security_group_ids = [
        data.aws_security_group.app_sg.id                   # ITF_SG_DR-WebAccess
    ]

    tags = {
        Name = "VPCE-SSMMessages"
    }
} 

resource "aws_vpc_endpoint" "ssm" {
    vpc_id = var.vpc_id 
    service_name = "com.amazonaws.us-east-1.ssm"
    vpc_endpoint_type = "Interface" 
    subnet_ids = [
        data.aws_subnet.app_subnet.id,                      # PrivateSub_AZ1
        data.aws_subnet.private_az2.id                      # PrivateSub_AZ2
    ]

    security_group_ids = [
        data.aws_security_group.app_sg.id                   # ITF_SG_DR-WebAccess
    ]

    tags = {
        Name = "VPCE-SSM"
    }
} 

resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id = var.vpc_id 
    service_name = "com.amazonaws.us-east-1.ec2messages"
    vpc_endpoint_type = "Interface" 
    subnet_ids = [
        data.aws_subnet.app_subnet.id,                      # PrivateSub_AZ1
        data.aws_subnet.private_az2.id                      # PrivateSub_AZ2
    ]

    security_group_ids = [
        data.aws_security_group.app_sg.id                   # ITF_SG_DR-WebAccess
    ]

    tags = {
        Name = "VPCE-EC2Messages"
    }
} 

# Application Load Balancer (ALB) 
resource "aws_lb" "app_alb" {
    name = "ALB-Primary-RegionA" 
    internal = false
    load_balancer_type = "application" 
    security_groups = [ data.aws_security_group.app_sg.id ]
    subnets = [
        data.aws_subnet.public_az1.id,
        data.aws_subnet.public_az2.id
    ]

    tags = {
        Name = "ALB-Primary-RegionA"
    }
}  

# ALB Listener
resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.app_alb.arn 
    port = 80
    protocol = "HTTP" 
    default_action {
        type = "forward" 
        target_group_arn = aws_lb_target_group.app_tg.arn
    }
}  

# Target Group for AppTier EC2 instance
resource "aws_lb_target_group" "app_tg" {
    name = "TargetGroup-RegionA" 
    port = 80
    protocol = "HTTP" 
    target_type = "instance"
    vpc_id = var.vpc_id 

    health_check {
        path = "/health" 
        protocol = "HTTP"
        matcher = "200" 
        interval = 30
        timeout = 5 
        healthy_threshold = 3
        unhealthy_threshold = 2
    }

    tags = {
        Name = "TargetGroup-RegionA"
    }
}  

# Attach AppTier instance to ALB Target Group
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
    target_group_arn = aws_lb_target_group.app_tg.arn 
    target_id = aws_instance.AppTier_Private-ITF_AZ1.id
    port = 80
}
