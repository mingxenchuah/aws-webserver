#!/bin/bash

mkdir logs

source ./scripts/vars.sh

source ./scripts/packer_build.sh

source ./scripts/terraform_deploy.sh