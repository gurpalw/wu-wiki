module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.51.0"

  name             = "gurps"
  cidr             = "10.0.0.0/16"
  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

resource "aws_route" "nat_route" {
  count = length(module.vpc.private_subnets)

  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_eip.nat-elastic-ips[count.index].network_interface

  timeouts {
    create = "5m"
  }
}