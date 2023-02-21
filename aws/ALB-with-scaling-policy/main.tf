terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "eu-central-1"
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-065deacbcaac64cf2" # ubuntu 22.04
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  key_name = "my-key-pair"
  user_data = <<-EOF
             #!/bin/bash

              wait
              cd /home/ubuntu || exit
              wait
              sudo touch index.txt
              sudo chown ubuntu:ubuntu index.txt
              EC2_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              SECURITY_GROUPS=$(curl -s http://169.254.169.254/latest/meta-data/security-groups)
              AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
              LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
              INTERFACE=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/)


              echo '<center><h1>Hello, from test page!</center></h1>' > index.txt
              # shellcheck disable=SC2129
              echo '<left><h2> The Instance <i>ID</i> of this Amazon EC2 instance is: EC2_ID </h2></left>' >> index.txt
              echo '<left><h2> The Instance placement <i>AZ</i> is: EC2_AVAIL_ZONE </h2></left>' >> index.txt
              echo '<left><h2> The Instance <i>ipv4</i> address is: IP_ADDRESS </h2></left>' >> index.txt
              echo '<left><h2> The Instance <i>security groups</i> is: SECURITY_GROUPS </h2></left>' >> index.txt
              echo '<left><h2> The Instance <i>AMI ID</i> is: AMI_ID </h2></left>' >> index.txt
              echo '<left><h2> The Instance <i>Local IP</i> address is: LOCAL_IP </h2></left>' >> index.txt


              sed -i "s/EC2_ID/$EC2_ID/" index.txt
              sed -i "s/EC2_AVAIL_ZONE/$EC2_AVAIL_ZONE/" index.txt
              sed -i "s/IP_ADDRESS/$IP_ADDRESS/" index.txt
              sed -i "s/SECURITY_GROUPS/$SECURITY_GROUPS/" index.txt
              sed -i "s/AMI_ID/$AMI_ID/" index.txt
              sed -i "s/LOCAL_IP/$LOCAL_IP/" index.txt
              sed -i "s/EC2_AVAIL_ZONE/$EC2_AVAIL_ZONE/" index.txt

              cp index.txt index.html


              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name =  "my_autoscaling_group"

  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 4

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

#resource "aws_autoscalingplans_scaling_plan" "example" {
#  name = "example-dynamic-cost-optimization"
#  application_source {
#    tag_filter {
#      key = "application"
#      values = ["example"]
#    }
#  }
#  scaling_instruction {
#    max_capacity       = 4
#    min_capacity       = 2
#    resource_id        = format("autoScalingGroup/%s",aws_security_group.instance.name)
#    scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
#    service_namespace  = "autoscaling"
#
#    target_tracking_configuration {
#      predefined_scaling_metric_specification {
#
#        predefined_scaling_metric_type = "ALBRequestCountPerTarget"
#       # resource_label = "${ .arn_suffix}/${tg.arn_suffix}"
#        resource_label = "${aws_lb.example.arn_suffix}/${aws_lb_target_group.asg.arn_suffix}"
#      }
#      target_value = 20
#    }
#  }
#}
###################################################################

resource "aws_security_group" "instance" {
  vpc_id = data.aws_vpc.default.id
  name = var.instance_security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_policy" "my_autoscaling_policy" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  name                   = "my_autoscaling_policy"
  adjustment_type        = "ChangeInCapacity"
  ## cooldown               = 100
  policy_type = "TargetTrackingScaling"
  # scaling_adjustment     = 4
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_lb.example.arn_suffix}/${aws_lb_target_group.asg.arn_suffix}"

    }

    target_value = 20
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

}

resource "aws_lb" "example" {

  name = var.alb_name

  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
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

  vpc_id = data.aws_vpc.default.id

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