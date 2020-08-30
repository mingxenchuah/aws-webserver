terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "load_balancer" {
  name_prefix = "lb-"
  description = "Allow IPV4 HTTP traffic"
  vpc_id      = var.vpc_id

  # HTTP access from internet
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Forward HTTP traffic
  egress {
    description     = "HTTP forwarding"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "Exercise Load balancer"
  }
}

resource "aws_security_group" "webserver" {
  name_prefix = "ws-"
  description = "Allow IPV4 HTTP inbound traffic"
  vpc_id      = var.vpc_id

  # HTTP access from ELB
  ingress {
    description = "HTTP access from ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.load_balancer.id ]
  }

  tags = {
    Name = "Exercise Webserver"
  }

  depends_on = [ aws_security_group.load_balancer ]
}

resource "aws_launch_configuration" "this" {
  name_prefix       = "ws-"
  image_id          = var.image_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  enable_monitoring = false
  security_groups   = [ aws_security_group.webserver.id ]
  user_data         = file("start_webserver.sh")

  depends_on = [ aws_security_group.webserver ]
}

resource "aws_autoscaling_group" "this" {
  name_prefix               = "ws-"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  target_group_arns         = [ aws_lb_target_group.this.id ]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  wait_for_elb_capacity     = 1
  launch_configuration      = aws_launch_configuration.this.id
  vpc_zone_identifier       = var.subnet_id_list

  depends_on = [
    aws_launch_configuration.this,
    aws_lb_target_group.this
  ]
}

resource "aws_lb_target_group" "this" {
  name_prefix = "ws-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "HTTP"
    port     = 80
    path     = "/"
    matcher  = "200"
  }

  tags = {
    Name = "Exercise Target Group"
  }
}

resource "aws_lb" "this" {
  name_prefix        = "ws-"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [ aws_security_group.load_balancer.id ]
  subnets            = var.subnet_id_list

  tags = {
    Name = "Exercise Application Load Balancer"
  }

  depends_on = [ aws_security_group.load_balancer ]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [
    aws_lb.this,
    aws_lb_target_group.this
  ]
}
