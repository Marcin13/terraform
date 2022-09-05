terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

  }

}

resource "aws_db_instance" "my_db" {
  instance_class = "db.t2.micro"
  identifier_prefix = "terraform-db"
  engine = "mysql"
  allocated_storage = 10
  db_name = "my_dataBase"
  username = "db_user"
#  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  password = "password123"
  skip_final_snapshot  = true
  publicly_accessible = true



}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "data_sekret_pass"
}
#output "key" {
#  sensitive = true
#  value = jsonencode(data.aws_secretsmanager_secret_version.db_password.secret_string)
#}