provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_launch_template" "my_LT" {
  name                   = var.lt_name
  instance_type          = "t2.micro"
  image_id               = "ami-065deacbcaac64cf2" # ubuntu 22.04
  security_group_names   = [var.sg_name]
  update_default_version = true
  key_name               = "my-key-pair"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 10
      delete_on_termination = "true"
      volume_type           = "gp2"
    }

  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "my_instance"
    }
  }
  # user_data = data.template_file.user_data.rendered
  user_data = filebase64("/user-data.sh")
}

# template file in not working for some reason

#data "template_file" "user_data" {
#  template = file("user-data.sh")
#
#  vars = {
#    server_port = var.server_port
#    az = "az"
#     #az          = data.aws_instance.server.availability_zone
#    ip = "ip"
#     #ip = data.aws_instance.server.public_ip
#    # db_port     = data.terraform_remote_state.db.outputs.port
#  }
#}
