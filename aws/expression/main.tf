provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

locals {
  digit = 0
}

variable "String_heredoc" {
  description = "String_heredoc example"
  type        = string
  default     = <<EOF
        "max-size": "8m",
        "min-size": "1m",
        "count": "8",
        "type": "string",
EOF
}

variable "number" {
  description = "Number example"
  type        = number
  default     = 6.3
}


variable "String" {
  description = "String example"
  type        = string
  // default     = "Hello, %{ if local.digit !="" }${local.digit}%{ else } No number %{ endif }!"
  default = "text"
}




variable "bool" {
  description = "bool example"
  type        = bool
  default     = false
}

variable "no_type" {
  description = "no_type example"
  type        = any
  default     = null
}

variable "list_tuple" {
  description = "list example"
  type        = list(any)
  default     = ["one", "two"]
}

variable "ingress" {
  type = list(object({
    external = number
    protocol = number
  }))
  default = [
    {
      external = 446
      protocol = "tcp"
    }
  ]
}

output "main" {
  value = "Hello, %{if var.no_type == 0} 0 %{else}${var.String} %{endif}"
}

output "String" {
  value = var.String_heredoc
}
output "key_value" {
  value = {for k, v in var.docker_ports :  (k) => (v) }
}
output "upper_obj" {
  value = {for s in var.list_tuple : title(s) => upper(s) }
}

output "upper_tuple" {
  value = [for s in var.list_tuple : upper(s) ]
}
