# Deploy Web Application to AWS

This is a fully automated solution to deploy a Python web application to AWS.

## Stack

* Linux
* Docker
* Packer
* Ansible
* Terraform
* Python
* AWS

## Usage

### Requirements

1. Linux machine requirement:

* internet access
* Git CLI
* Docker

2. AWS account requirement:

* IAM user with Autoscaling and Elastic Load Balancing roles.
* Access key for IAM user.
* VPC with minimum 2 subnets (1 subnet in each availability zone), internet gateway, and routes configured.
* EC2 key pair.

### Assumptions

* No proxy.
* Internet access without restriction to Docker Hub, GitHub, Linux repositories, etc.

### How To

1. Clone Git repository.
2. Edit variables file **./src/vars/vars.sh**
3. Execute shell script to deploy. On successful deploy, the website URL will be printed to console.
```
./deploy.sh
```
4. Execute shell script to tear down.
```
./destroy.sh
```

## Design

### Architecture

Breakdown of automated deployment steps:

1. Build Docker image.
2. Start Docker container with **src** folder mounted.
3. Build AMI using Packer. Packer calls Ansible Playbook to customise OS and deploy application.
4. Terraform deploys infrastructure.

Automated tear down:

* All AWS assets deployed using Terraform is destroyed.

Application:

* Python Flask web application wrapped in Python Waitress web server.

Infrastructure assets:

* EC2 instance
* Auto scaling group
* Launch configuration
* Security groups
* AMI
* EBS snapshot
* Application load balancer
* Load balancer target group

Infrastructure security:

* Only IPv4 is used infrastructure wide. This includes OS level config, AWS load balancers, and AWS security groups.
* SELinux is enabled and set to ENFORCE on the OS.
* Application (EC2) instances are launched into a security group which only allow incoming HTTP (port 80) traffic from the load balancer security group.
* Load balancer security group only accepts and forwards HTTP (port 80) traffic.
* Python Waitress is used as a wrapper for the web application for improved security.

Infrastructure self-healing:

* Auto scaling group monitors EC2 instance and web server health (HTTP status 200).
* An unhealthy web server is replaced with a new EC2 instance which the auto scaling group automatically registers with the load balancer.

Infrastructure monitoring:

* Cloud watch default monitoring is available for monitoring EC2 instance metrics, auto scaling group activity, and load balancer activity.

### Considerations

1. Shell scripts are used to chain the different stages in place of a CI/CD tool like Jenkins. Jenkins pipeline is preferred but that would add unnecessary complexity to this exercise.
2. All tooling dependencies are managed in a Docker container.
3. **src** folder is mounted to the Docker container instead of copied so that log and Terraform state files persists after container is removed. Docker containers are run with the --rm flag to avoid dangling containers.
4. AMI is pre-baked using Packer at the start. This enables a standard use-case specific AMI ready to be dropped into a launch config without requiring any post-launch steps.
5. Python web application source files should be decoupled and hosted in a separate Git repository and pulled at runtime but is included in this repository sake of simplicity.
6. Auto scaling group will only maintain 1 EC2 instance (min=1, max=1).
7. OS level firewall is not used (unnecessary redundancy) because security group is completely locked down to allow only incoming port 80 traffic from load balancer.
