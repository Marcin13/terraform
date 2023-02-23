variable "aws_region" {
  description = "Aws Region"
  type = string
  default = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS Profile"
  type = string
  default = "default"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type = string
  default = "My Server"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for the name of the security group"
  default = "Web_server_sg"
}

variable "ingress_ports" {
  type = map(object({
    from_port   = number
    to_port     = number
    description = string
  }))
  description = "A map of ingress ports to open"
  default = {
    http = {
      from_port   = 80
      to_port     = 80
      description = "Allow HTTP traffic"
    }
    https = {
      from_port   = 443
      to_port     = 443
      description = "Allow HTTPS traffic"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      description = "Allow SSH traffic"
    }
  }
}

variable "egress_rules" {
  type = map(object({
    from_port   = number
    to_port     = number
    description = string
  }))
  description = "A map of egress rules to apply"
  default = {
    all_outbound = {
      from_port   = 0
      to_port     = 0
      description = "Allow all outbound traffic"
    }
  }
}