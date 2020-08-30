#!/bin/bash

echo -e '\n\n========== DESTROY INFRASTRUCTURE ==========\n\n'

cd /src/terraform

terraform destroy -auto-approve
