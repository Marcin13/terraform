variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "My_Server"
}
variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "web_access"
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}
variable "ssh_port" {
  description = "The port for ssh"
  type        = number
  default     = 22
}
variable "tags" {
  type = map(string)
  default = {
    Env     = "dev"
    Service = "web"
    Name    = "web-server"
    Role    = "web"
    Team    = "devops"
  }
}