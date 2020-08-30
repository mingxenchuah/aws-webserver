#!/bin/bash

echo -e '\n\n========== DEPLOY INFRASTRUCTURE ==========\n\n'

cd /src/terraform

cat > terraform.tfvars <<EOF
aws_region="$AWS_REGION"
aws_access_key="$AWS_ACCESS_KEY"
aws_secret_key="$AWS_SECRET_KEY"
image_id="$AMI_ID"
instance_type="$INSTANCE_TYPE"
vpc_id="$VPC_ID"
subnet_id_list=$SUBNET_ID_LIST
key_name="$KEY_PAIR_NAME"
EOF

terraform init -input=false

terraform plan -input=false -out=terraform.tfplan

terraform apply -input=false -auto-approve terraform.tfplan
