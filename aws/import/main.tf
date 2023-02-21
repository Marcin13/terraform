// Provider configuration
terraform {
  cloud {
    organization = "M4r6inOrg"

    workspaces {
      name = "Testing"
    }

    }
  }

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

resource "aws_instance" "my-vm" {
  ami = "ami-04706e771f950937f"

  instance_type = "t2.micro"
tags = {
  Name = "My_server"
}
}


// terraform import aws_instance.myvm i-0e7ca39740cfe8da0