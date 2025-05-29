resource "aws_vpc_endpoint" "ssm" {
    vpc_id = "vpc-08f94ba54ced6f05d"
    service_name = "com.amazonaws.us-east-1.ssm"
    vpc_endpoint_type = "Interface"

    subnet_ids = [
        "subnet-087fa0f8ccbc50ee1",  # PrivateSub_AZ1
        "subnet-0e2c62cc284851a28"   # PrivateSub_AZ2
    ]

    security_group_ids = [ "sg-09d980b49ea7c9e54" ]  # ITF_SG_DR-WebAccess

    tags = {
        Name = "VPCE-SSM"
    }
}



resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id = "vpc-08f94ba54ced6f05d"
    service_name = "com.amazonaws.us-east-1.ec2messages"
    vpc_endpoint_type = "Interface"

    subnet_ids = [
        "subnet-087fa0f8ccbc50ee1",  # PrivateSub_AZ1
        "subnet-0e2c62cc284851a28"   # PrivateSub_AZ2
    ]

    security_group_ids = [ "sg-09d980b49ea7c9e54" ]  # ITF_SG_DR-WebAccess

    tags = {
        Name = "VPCE-EC2Messages"
    }
}



resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id = "vpc-08f94ba54ced6f05d"
    service_name = "com.amazonaws.us-east-1.ssmmessages"
    vpc_endpoint_type = "Interface"

    subnet_ids = [
        "subnet-087fa0f8ccbc50ee1",  # PrivateSub_AZ1
        "subnet-0e2c62cc284851a28"   # PrivateSub_AZ2
    ]

    security_group_ids = [ "sg-09d980b49ea7c9e54" ]  # ITF_SG_DR-WebAccess

    tags = {
        Name = "VPCE-SSMMessages"
    }
}
