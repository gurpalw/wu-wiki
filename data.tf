data "aws_ami" "nat_instance_ami" {
  owners = ["137112412989"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-2018.03*"]
  }
}
