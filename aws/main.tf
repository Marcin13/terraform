provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_instance" "app_server" {
  ami             = "ami-0e2031728ef69a466"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    ## Name = "ExampleAppServerInstance"
    Name = var.instance_name
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum upgrade -y
              sudo amazon-linux-extras install nginx1 -y
              sudo /etc/init.d/nginx start
              EOF
}
## Required when using a launch configuration with an auto scaling group.
## https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
#lifecycle {
#  create_before_destroy = true
#}

resource "aws_security_group" "instance" {

  name = var.security_group_name
  ingress {
    description = "allow port 80"
    from_port   = var.server_port
    protocol    = "tcp"
    to_port     = var.server_port
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "allow all on ssh port"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}