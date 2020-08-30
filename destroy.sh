#!/bin/bash

docker run --rm -t \
    -v $(pwd)/src:/src exercise/builder:latest \
    /bin/bash -c './scripts/terraform_destroy.sh'
