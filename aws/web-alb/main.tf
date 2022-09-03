provider "aws" {
  profile = "default"
  region  = "eu-central-1"

  # Allow any 2.x version of the AWS provider
#  version = "~> 2.0"
}

#resource "aws_launch_configuration" "my_lc" {
#  image_id        = "ami-065deacbcaac64cf2" # ubuntu 22.04
#  instance_type   = "t2.micro"
#  security_groups = [aws_security_group.instance.id]
#
#
#  user_data       = data.template_file.user_data.rendered
#
#  # Required when using a launch configuration with an auto scaling group.
#  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
#  lifecycle {
#    create_before_destroy = true
#  }
#}

#data "template_file" "user_data" {
#  template = file("user-data.sh")
#
#  vars = {
#    server_port = var.server_port
#    #subnets_id  = data.aws_subnet_ids.default.id
#    # db_port     = data.terraform_remote_state.db.outputs.port
#  }
#}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
data "aws_launch_template" "my_LT" {
  name = "My_Server"
}

resource "aws_autoscaling_group" "my_asg" {
  name = var.auto_scaling_group_name
  launch_template {
    id = data.aws_launch_template.my_LT.id
    version =data.aws_launch_template.my_LT.latest_version
  }

  #availability_zones = [data.aws_subnet_ids.default.ids]
  ##vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  ##target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
  health_check_grace_period = 100
  force_delete          = true

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }


  tag {
    key                 = "Name"
    value               = "my_asg_instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "my_asp" {
  autoscaling_group_name = var.auto_scaling_group_name
  name = "foobar"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "my_asg_instance"

    }
    target_value = 10
  }
}

resource "aws_security_group" "instance" {
  name = var.instance_security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTP requests
  ingress {
    description = "Allow port 80 for HTTP"
    from_port   = "80"
    protocol    = "tcp"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH requests
  ingress {
    description = "Allow port ${var.ssh_port} for SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    description = "Allow all ports from all IPs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {

  name               = var.alb_name

  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {

  name = var.alb_name

  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_security_group" "alb" {

  name = var.alb_security_group_name

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}