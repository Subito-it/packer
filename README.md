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
