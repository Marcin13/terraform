provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "instance" {
  ami                    = "ami-065deacbcaac64cf2" # ubuntu 22.04
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = data.template_file.user_data.rendered

  tags = {
    for key, value in var.tags :
    key => value
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("user-data.sh")

  vars = {
    server_port = var.server_port
  }
}
#data "aws_vpc" "default" {
#  default = true
#}

resource "aws_security_group" "security_group" {

  name = var.security_group_name

  # Allow inbound HTTP requests
  ingress {
    description = "Allow port ${var.server_port} for HTTP"
    from_port   = var.server_port
    protocol    = "tcp"
    to_port     = var.server_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH requests
  ingress {
    description = "Allow port ${var.ssh_port} for SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    description = "Allow all ports from all IPs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    for key, value in var.tags :
    key => value
  }
}