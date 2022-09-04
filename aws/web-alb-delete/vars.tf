variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "auto_scaling_group_name" {
  description = "The name of auto scaling group"
  type        = string
  default     = "my_ASG_name"
}

variable "alb_name" {
  description = "The name of the ALB"
  type        = string
  default     = "terraform-asg-example"
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  type        = string
  default     = "sg for terraform instance"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
  default     = "terraform-example-alb"
}
variable "ssh_port" {
  description = "The port for ssh"
  type        = number
  default     = 22
}