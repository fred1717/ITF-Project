# EC2 instance for AppTier in PrivateSub_AZ1 with SSM agent enabled
resource "aws_instance" "AppTier_Private-ITF_AZ1" {

  # Amazon Linux 2 AMI (for us-east-1)
  ami                    = "ami-0f88e80871fd81e91"

  # Instance type
  instance_type          = "t2.micro"

  # Dynamically resolved subnet ID (PrivateSub_AZ1)
  subnet_id              = data.aws_subnet.app_subnet.id

  # Dynamically resolved security group
  vpc_security_group_ids = [data.aws_security_group.app_sg.id]

  # IAM role with SSM and logging permissions
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # EC2 key pair for optional SSH access
  key_name               = "your-key-name"                     # Replace with your EC2 key pair name

  # Reference to external user_data script to enable SSM agent
  user_data              = templatefile("${path.module}/scripts/user_data.sh", {})

  # EC2 instance tags
  tags = {
    Name = "AppTier_Private-ITF_AZ1"
  }
}
