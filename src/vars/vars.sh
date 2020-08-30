#!/bin/bash

# AWS credentials
AWS_ACCESS_KEY="some_value"
AWS_SECRET_KEY="some_value"
AWS_REGION="ap-southeast-2"

# EC2 build config
INSTANCE_TYPE="t2.micro"
KEY_PAIR_NAME="some_name"
VPC_ID="vpc-123456"
# Minimum 2 subnets across 2 AZ's required.
SUBNET_ID_LIST='["subnet-123456","subnet-654321"]'
