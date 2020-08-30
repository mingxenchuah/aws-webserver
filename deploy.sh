#!/bin/bash

docker build . -t exercise/builder:latest

docker run --rm -t \
    -v $(pwd)/src:/src exercise/builder:latest \
    /bin/bash -c './scripts/deploy.sh'
