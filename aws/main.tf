terraform {
  cloud {
    organization = "m4r6cinorg"

    workspaces {
      name = "x230"
    }
  }
}


provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-03e88be9ecff64781"
  instance_type = "t2.micro"
  security_groups = ["web-acces"]
  tags = {
    ## Name = "ExampleAppServerInstance"
    Name = var.instance_name
  }
}
