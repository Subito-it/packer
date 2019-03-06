# Build an AMI with Packer

## Abstract

This repo contains some examples about using Packer to build AMI in AWS. It is intended as an introductive guide to create a repeatable an predictable process to deploy your artifacts with EC2 instances.  
This method was presented at [Incontro DevOps Italia 2019](https://2019.incontrodevops.it/talks.html#gianluca-mascolo) (Italian DevOps Gathering 2019).

## Prerequisites

You should have a working Linux, BSD or Mac installation on your computer and a valid AWS account with [AWS CLI](https://aws.amazon.com/cli/) already installed and configured. The AWS CLI tools will not be used here but the credentials file configured on your computer will be used to access your account, deploy instances and other stuff.

## Installation

Before using the code you must have installed and available in your PATH the following tools:
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Packer](https://www.packer.io/downloads.html)
- [Terraform](https://www.terraform.io/downloads.html)

## Webserver AMI Build

Change directory to packer-profiles
```
]$ cd packer-profiles/
]$ ls
mini-example.json  webserver.json
]$
```
Set the following environment variables with appropriate values regarding your AWS account
```
export AWS_DEFAULT_REGION="eu-west-1"
export AWS_PROFILE="default"
```
AWS profile must match the section name found in your ~/.aws/credentials file. If you only manage one account this is usually set to `default`. Now to build the a web server you will use webserver.json. Before doing it let's set the last environment variable used by it:
```
export PACKER_PROFILE="webserver"
```
This will be used by webserver.json to name your AMI and identify the ansible playbook to install it. Now let's build it
```
packer build webserver.json
```
