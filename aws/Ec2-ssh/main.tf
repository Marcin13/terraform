terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.71.0"
    }
  }
  required_version = ">= 1.1.0"
#  backend "s3" {
#    bucket = "my-terraform-state-bucket"
#    key    = "my-terraform-state-key"
#    region = "us-west-2"
#  }
#  experimental {
#    workspace_dir = ".terraform/workspaces"
#  }

#  cloud {
#    organization = "m4r6cinorg"
#
#    workspaces {
#      name = "x230"
#    }
#  }

  # Uncomment the following line to enable detailed logs
  # log_path = "terraform.log"
}


provider "aws" {
# alias (string): An optional alias for the provider.
# version (string): The version of the provider to use. If not specified, the latest version will be used.
# credentials (map): A set of credentials to use when authenticating with the provider.
# region (string): The default region to use when working with the provider.
  region  = var.aws_region
# access_key (string): The access key to use when authenticating with the provider.
# secret_key (string): The secret key to use when authenticating with the provider.
# token (string): The session token to use when authenticating with the provider.
# profile (string): The named profile to use when authenticating with the provider.
  profile = "default"
# endpoints (map): A set of custom endpoints to use when working with the provider.
# ignore_tags (bool): If set to true, Terraform will ignore all Tags when interacting with the provider.
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.name]
  key_name = aws_key_pair.my_key_pair.key_name
  tags = {
    Name = var.instance_name
  }
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "ansible"
  public_key = file("${path.module}./.ssh/ansible.pub")
}

resource "aws_security_group" "web_server_sg" {
  name = var.name_prefix

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = egress.value.description
    }
  }
  tags = {
    Name = "Web Server Security Group"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

