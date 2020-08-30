#!/bin/bash

# AWS credentials
AWS_ACCESS_KEY=""
AWS_SECRET_KEY=""
AWS_REGION=""

# EC2 build config
INSTANCE_TYPE=""
KEY_PAIR_NAME=""
VPC_ID=""
# Minimum 2 subnets across 2 AZ's required.
SUBNET_ID_LIST='["",""]'
