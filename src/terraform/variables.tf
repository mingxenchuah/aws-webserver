variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "image_id" {
  type        = string
  description = "EC2 image ID."
}

variable "instance_type" {
  type        = string
  description = "Desired EC2 instance type."
}

variable "vpc_id" {
  type = string
}

variable "subnet_id_list" {
  type = list(string)
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name."
}
