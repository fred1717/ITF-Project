# EC2 instance for AppTier in PrivateSub_AZ1 with SSM agent enabled
resource "aws_instance" "AppTier_Private-ITF_AZ1" {

  # AMI used (Amazon Linux 2023)
  ami           = "ami-0f88e80871fd81e91"

  # Instance type
  instance_type = "t2.micro"

  # Subnet where the instance will be deployed (PrivateSub_AZ1)
  subnet_id     = "subnet-087fa0f8ccbc50ee1"

  # Use existing Elastic IP (optional if already associated manually)
  associate_public_ip_address = false

  # IAM role with SSM and S3 permissions
  iam_instance_profile = "EC2SSMRole"

  # Security group for this EC2 instance
  vpc_security_group_ids = ["sg-09d980b49ea7c9e54"]  # ITF_SG_DR-WebAccess

  # EC2 user data to install and start the SSM agent on boot
  user_data = templatefile("${path.module}/scripts/user_data.sh", {})

  # Tag for identification
  tags = {
    Name = "AppTier_Private-ITF_AZ1"
  }
}
