provider "aws" {
  profile = "gmail"
  region  = local.region
}


locals {
  name   = "my-${replace(basename(path.cwd), "_", "-")}"
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

## small change
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names

#  private_subnets = slice(var.private_subnet_cidr_blocks, 0, 2)
#  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, 2)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  // private_subnet_names = ["Private Subnet One", "Private Subnet Two","Private Subnet three" ]
  private_subnet_tags = {
    Terraform = "true"
  }

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}