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

resource "aws_security_group" "webserver" {
  name        = "Webserver"
  description = "Allow IPV4 HTTP and SSH inbound traffic"
  vpc_id      = var.vpc_id

  # HTTP access from anywhere
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # SSH access from anywhere
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "Webserver"
  }
}

resource "aws_launch_configuration" "webserver" {
  name_prefix       = "webserver-lc-"
  image_id          = var.image_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  enable_monitoring = false
  security_groups = [
    aws_security_group.webserver.id
  ]
  user_data = file("start_webserver.sh")

  depends_on = [
    aws_security_group.webserver
  ]
}

resource "aws_autoscaling_group" "webserver" {
  name_prefix          = "webserver-asg-"
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.webserver.id
  vpc_zone_identifier  = [var.subnet_id]

  depends_on = [aws_launch_configuration.webserver]
}
