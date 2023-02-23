terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

  }

}
provider "aws" {
  profile = "gmail"
  region  = "eu-central-1"
}

resource "aws_db_instance" "my_db" {
  identifier     = "lara-bd-pro"
  db_name        = "LaraDB_PRO"
  instance_class = "db.t2.micro"
  #identifier_prefix = "terraform-db-pro"
  engine            = "mysql"
  allocated_storage = 10

  username = "lara"
  #  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  password            = "password123"
  skip_final_snapshot = true
  publicly_accessible = true

  tags = {
    Environment = "Production"
  }
  # Use for_each to loop over var.custom_tags
  #    dynamic "default_tags" {
  #      for_each = var.custom_tags
  #      content {
  #        key                 = default_tags.key
  #        value               = default_tags.value
  #        propagate_at_launch = true
  #
  #      }
  #    }

}

resource "aws_db_instance" "my_db2" {

  identifier     = "lara-db-dev"
  db_name        = "LaraDB_DEV"
  instance_class = "db.t2.micro"
  #identifier_prefix = "terraform-db-dev"
  engine            = "mysql"
  allocated_storage = 10

  username = "lara"
  #  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  password            = "password123"
  skip_final_snapshot = true
  publicly_accessible = true

  tags = {
    Environment = "Development"
  }
  # Use for_each to loop over var.custom_tags
  #      dynamic "Tags" {
  #        for_each = var.custom_tags
  #        content {
  #          key                 = Tags.key
  #          value               = Tags.value
  #          propagate_at_launch = true
  #
  #        }
  #      }

}



variable "db_name" {
  description = "Dara Base name"
  type        = list(any)
  default     = ["Larablogger", "Larablogger2"]

}
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default = {
    "key"   = "Production"
    "value" = "Environment"
  }
}




#data "aws_secretsmanager_secret_version" "db_password" {
#  secret_id = "data_sekret_pass"
#}
output "Hostname_of_the_RDS_instance" {
  value = aws_db_instance.my_db.address
}
output "initial_database_name" {
  value = aws_db_instance.my_db.db_name
}
output "Port" {
  value = aws_db_instance.my_db.port
}
output "Endpoint" {
  value = aws_db_instance.my_db.endpoint
}