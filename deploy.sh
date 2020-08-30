#!/bin/bash

echo -e '\n\n========== BUILD DOCKER IMAGE ==========\n\n'

docker build . -t exercise/builder:latest

echo -e '\n\n========== STARTING BUILD & DEPLOY ==========\n\n'

docker run --rm -t \
    -v $(pwd)/src:/src exercise/builder:latest \
    /bin/bash -c './scripts/deploy.sh'
