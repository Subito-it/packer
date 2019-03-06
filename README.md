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
You should get an output similar to the following one
<details><summary>packer build output</summary>
<p>

``` 
]$ packer build webserver.json
amazon-ebs output will be in this color.

==> amazon-ebs: Prevalidating AMI Name: webserver_1551909005
    amazon-ebs: Found Image ID: ami-0bfb4cded51a2ab3e
==> amazon-ebs: Creating temporary keypair: packer_5c80408d-1ad6-3b57-e06f-a75bc7053184
==> amazon-ebs: Creating temporary security group for this instance: packer_5c80409b-c9da-2f51-90cb-095a03b9a481
==> amazon-ebs: Authorizing access to port 22 from 0.0.0.0/0 in the temporary security group...
==> amazon-ebs: Launching a source AWS instance...
==> amazon-ebs: Adding tags to source instance
    amazon-ebs: Adding tag: "Name": "Packer Builder"
    amazon-ebs: Instance ID: i-0b3edb7d2e9574849
==> amazon-ebs: Waiting for instance (i-0b3edb7d2e9574849) to become ready...
==> amazon-ebs: Using ssh communicator to connect: 34.245.218.28
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Provisioning with Ansible...
==> amazon-ebs: Executing Ansible: ansible-playbook --extra-vars packer_build_name=amazon-ebs packer_builder_type=amazon-ebs -o IdentitiesOnly=yes -i /tmp/packer-provisioner-ansible978552682 /home/gmascolo/Programs/packer/ansible-playbooks/webserver.yml -e ansible_ssh_private_key_file=/tmp/ansible-key734980727
    amazon-ebs:
    amazon-ebs: PLAY [webserver] ***************************************************************
    amazon-ebs:
    amazon-ebs: TASK [Gathering Facts] *********************************************************
    amazon-ebs: ok: [webserver]
    amazon-ebs:
    amazon-ebs: TASK [Timezone Configuration] **************************************************
    amazon-ebs: changed: [webserver]
    amazon-ebs:
    amazon-ebs: TASK [Install Packages] ********************************************************
    amazon-ebs: changed: [webserver]
    amazon-ebs:
    amazon-ebs: TASK [Enable Apache Web Server] ************************************************
    amazon-ebs: changed: [webserver]
    amazon-ebs:
    amazon-ebs: TASK [Create index.html] *******************************************************
    amazon-ebs: changed: [webserver]
    amazon-ebs:
    amazon-ebs: PLAY RECAP *********************************************************************
    amazon-ebs: webserver                  : ok=5    changed=4    unreachable=0    failed=0
    amazon-ebs:
==> amazon-ebs: Stopping the source instance...
    amazon-ebs: Stopping instance, attempt 1
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating unencrypted AMI webserver_1551909005 from instance i-0b3edb7d2e9574849
    amazon-ebs: AMI: ami-02e1f279cf40e8873
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-1: ami-02e1f279cf40e8873

]$

```

</p>
</details>
At the end of this process (usually a few minutes) you will notice an AMI named like `webserver_1551909005` in your AWS account.

## Webserver AMI deployment

Now let's deploy the AMI you just created with terraform. Change directory to terraform:
```
]$ cd ../terraform/
]$ ls
00-account.tf  01-security_groups.tf  02-ec2_instance.tf  terraform.tfvars.example
]$
```
To use terraform you must set terraform variables using terraform.tfvars. Let's copy the example
```
cp terraform.tfvars.example terraform.tfvars
```
Open it with an editor and set AWS profile in a similar way as you have done for Packer, e.g.
```
]$ cat terraform.tfvars
aws_region = "eu-west-1"
aws_credentials_file = "~/.aws/credentials"
aws_profile = "default"
]$
```
Now init your terraform setup with
```
terraform init
```
<details><summary>terraform init output</summary>
<p>

``` 
]$ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (2.0.0)...
- Downloading plugin for provider "http" (1.0.1)...
- Downloading plugin for provider "tls" (1.2.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.0"
* provider.http: version = "~> 1.0"
* provider.tls: version = "~> 1.2"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
]$ 
```

</p>
</details>
