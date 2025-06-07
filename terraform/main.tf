# Fetch subnets dynamically
# Public Subnet AZ1
data "aws_subnet" "public_az1" {
  filter {
    name   = "tag:Name"
    values = ["ITF_PublicSub_AZ1"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Public Subnet AZ2
data "aws_subnet" "public_az2" {
  filter {
    name   = "tag:Name"
    values = ["ITF_PublicSub_AZ2"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Data source to dynamically fetch the subnet ID by tag and AZ
data "aws_subnet" "private_az1" {
  filter {
    name   = "tag:Name"
    values = ["ITF_PrivateSub_AZ1"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Private Subnet AZ2
data "aws_subnet" "private_az2" {
  filter {
    name   = "tag:Name"
    values = ["ITF_PrivateSub_AZ2"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Fetch security group dynamically
# Data source to dynamically fetch the security group ID by group name
data "aws_security_group" "app_sg" {
  filter {
    name   = "tag:Name"
    values = ["ITF_SG_DR-WebAccess"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# ALB
# Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "ALB-Primary-RegionA"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.app_sg.id]
  subnets            = [
    data.aws_subnet.public_az2.id,
    data.aws_subnet.public_az1.id
  ]

  tags = {
    Name = "ALB-Primary-RegionA"
  }
}

# Target Group for AppTier EC2 instance
resource "aws_lb_target_group" "app_tg" {
  name     = "TargetGroup-RegionA"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "TargetGroup-RegionA"
  }
}

# ALB Listeners
resource "aws_lb_listener" "http_listener" {
 load_balancer_arn = aws_lb.app_alb.arn
 port              = 80
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.app_tg.arn
 }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-east-1:180294215772:certificate/201063b7-6a4a-4cc6-93f7-6eef8d0565db"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Attach AppTier instance to ALB Target Group
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.AppTier_Private-ITF_AZ1.id
  port             = 80
}
