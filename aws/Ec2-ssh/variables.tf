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

