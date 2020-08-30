FROM debian:buster-slim

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Install OS utils
RUN apt-get clean && apt-get update
RUN apt-get install -y curl gnupg2 ssh unzip python3 python3-pip

# Install Packer, Terraform, Ansible
RUN curl -fsSL 'https://apt.releases.hashicorp.com/gpg' | apt-key add -
RUN echo 'deb [arch=amd64] https://apt.releases.hashicorp.com buster main' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y packer terraform
RUN pip3 install ansible

WORKDIR /tmp

# Install AWS-CLI
RUN curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
RUN unzip awscliv2.zip
RUN ./aws/install

# Create build user
# To avoid writing files as root to the mounted volume
RUN groupadd -g 1000 build
RUN useradd -g 1000 -u 1000 -m -d /home/build -s /bin/bash build

VOLUME [ '/src' ]

WORKDIR /src

USER build
