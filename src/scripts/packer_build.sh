#!/bin/bash

LOG_FOLDER="/src/logs"
BUILD_LOG_PATH="$LOG_FOLDER/packer_build.log"
AMI_LOG_PATH="$LOG_FOLDER/ami.log"

echo -e '\n\n========== BUILD CUSTOM AMI ==========\n\n'

packer build -machine-readable -debug \
    -var "aws_access_key=$AWS_ACCESS_KEY" \
    -var "aws_secret_key=$AWS_SECRET_KEY" \
    -var "aws_region=$AWS_REGION" \
    -var "instance_type=$INSTANCE_TYPE" \
    -var "vpc_id=$VPC_ID" \
    /src/packer/amzn2_custom.json | tee $BUILD_LOG_PATH

AMI_ID=$(grep 'artifact,0,id' $BUILD_LOG_PATH | cut -d, -f6 | cut -d: -f2)

if [ -z "$AMI_ID" ]
then
    echo "Packer build failed."
    exit
fi

echo $AMI_ID > $AMI_LOG_PATH
