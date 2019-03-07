# Build an AMI with Packer

## Abstract

This repo contains some examples about using Packer illustrateds during [Incontro DevOps Italia 2019](https://2019.incontrodevops.it/talks.html#gianluca-mascolo) 
It is intended as an introductive guide to create a repeatable an predictable process to deploy your artifacts with EC2 instances.

## Prerequisites

You should have a working Linux, BSD or Mac installation on your computer and a valid AWS account with [AWS CLI](https://aws.amazon.com/cli/) already installed and configured. The AWS CLI tools will not be used here but the credentials file configured on your computer will be used to access your account, deploy instances and other stuff.

## Installation

Before using the code you must have installed and available in your PATH the following tools:
- [Packer](https://www.packer.io/downloads.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
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
  
Check that everything is ready for your deployment
```
terraform validate
terraform plan
```
Terraform will show you a plan of what it wants to deploy in your AWS account

<details><summary>terraform plan output</summary>
<p>

``` 
]$ terraform validate
]$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.http.public_ip: Refreshing state...
data.aws_ami.webserver: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

 <= data.aws_subnet_ids.default_subnets
      id:                                        <computed>
      ids.#:                                     <computed>
      tags.%:                                    <computed>
      vpc_id:                                    "${aws_default_vpc.default_vpc.id}"

  + aws_default_vpc.default_vpc
      id:                                        <computed>
      arn:                                       <computed>
      assign_generated_ipv6_cidr_block:          <computed>
      cidr_block:                                <computed>
      default_network_acl_id:                    <computed>
      default_route_table_id:                    <computed>
      default_security_group_id:                 <computed>
      dhcp_options_id:                           <computed>
      enable_classiclink:                        <computed>
      enable_classiclink_dns_support:            <computed>
      enable_dns_hostnames:                      <computed>
      enable_dns_support:                        "true"
      instance_tenancy:                          <computed>
      ipv6_association_id:                       <computed>
      ipv6_cidr_block:                           <computed>
      main_route_table_id:                       <computed>
      owner_id:                                  <computed>

  + aws_instance.web
      id:                                        <computed>
      ami:                                       "ami-02e1f279cf40e8873"
      arn:                                       <computed>
      associate_public_ip_address:               "true"
      availability_zone:                         <computed>
      cpu_core_count:                            <computed>
      cpu_threads_per_core:                      <computed>
      ebs_block_device.#:                        <computed>
      ephemeral_block_device.#:                  <computed>
      get_password_data:                         "false"
      host_id:                                   <computed>
      instance_initiated_shutdown_behavior:      "terminate"
      instance_state:                            <computed>
      instance_type:                             "t2.micro"
      ipv6_address_count:                        <computed>
      ipv6_addresses.#:                          <computed>
      key_name:                                  "terraform-ssh-key"
      network_interface.#:                       <computed>
      network_interface_id:                      <computed>
      password_data:                             <computed>
      placement_group:                           <computed>
      primary_network_interface_id:              <computed>
      private_dns:                               <computed>
      private_ip:                                <computed>
      public_dns:                                <computed>
      public_ip:                                 <computed>
      root_block_device.#:                       "1"
      root_block_device.0.delete_on_termination: "true"
      root_block_device.0.volume_id:             <computed>
      root_block_device.0.volume_size:           "3"
      root_block_device.0.volume_type:           "standard"
      security_groups.#:                         <computed>
      source_dest_check:                         "true"
      subnet_id:                                 "${data.aws_subnet_ids.default_subnets.ids[0]}"
      tags.%:                                    "1"
      tags.Name:                                 "terraform packer deploy"
      tenancy:                                   <computed>
      volume_tags.%:                             <computed>
      vpc_security_group_ids.#:                  <computed>

  + aws_key_pair.terraform-ssh-key
      id:                                        <computed>
      fingerprint:                               <computed>
      key_name:                                  "terraform-ssh-key"
      public_key:                                "${tls_private_key.terraform-ssh-key.public_key_openssh}"

  + aws_security_group.http_in
      id:                                        <computed>
      arn:                                       <computed>
      description:                               "Allow HTTP Traffic"
      egress.#:                                  "1"
      egress.482069346.cidr_blocks.#:            "1"
      egress.482069346.cidr_blocks.0:            "0.0.0.0/0"
      egress.482069346.description:              ""
      egress.482069346.from_port:                "0"
      egress.482069346.ipv6_cidr_blocks.#:       "0"
      egress.482069346.prefix_list_ids.#:        "0"
      egress.482069346.protocol:                 "-1"
      egress.482069346.security_groups.#:        "0"
      egress.482069346.self:                     "false"
      egress.482069346.to_port:                  "0"
      ingress.#:                                 "1"
      ingress.627927811.cidr_blocks.#:           "1"
      ingress.627927811.cidr_blocks.0:           "REDACTED"
      ingress.627927811.description:             ""
      ingress.627927811.from_port:               "80"
      ingress.627927811.ipv6_cidr_blocks.#:      "0"
      ingress.627927811.prefix_list_ids.#:       "0"
      ingress.627927811.protocol:                "tcp"
      ingress.627927811.security_groups.#:       "0"
      ingress.627927811.self:                    "false"
      ingress.627927811.to_port:                 "80"
      name:                                      "http_in"
      owner_id:                                  <computed>
      revoke_rules_on_delete:                    "false"
      vpc_id:                                    "${aws_default_vpc.default_vpc.id}"

  + aws_security_group.ssh_in
      id:                                        <computed>
      arn:                                       <computed>
      description:                               "Allow SSH Traffic"
      egress.#:                                  "1"
      egress.482069346.cidr_blocks.#:            "1"
      egress.482069346.cidr_blocks.0:            "0.0.0.0/0"
      egress.482069346.description:              ""
      egress.482069346.from_port:                "0"
      egress.482069346.ipv6_cidr_blocks.#:       "0"
      egress.482069346.prefix_list_ids.#:        "0"
      egress.482069346.protocol:                 "-1"
      egress.482069346.security_groups.#:        "0"
      egress.482069346.self:                     "false"
      egress.482069346.to_port:                  "0"
      ingress.#:                                 "1"
      ingress.2584783984.cidr_blocks.#:          "1"
      ingress.2584783984.cidr_blocks.0:          "REDACTED"
      ingress.2584783984.description:            ""
      ingress.2584783984.from_port:              "22"
      ingress.2584783984.ipv6_cidr_blocks.#:     "0"
      ingress.2584783984.prefix_list_ids.#:      "0"
      ingress.2584783984.protocol:               "tcp"
      ingress.2584783984.security_groups.#:      "0"
      ingress.2584783984.self:                   "false"
      ingress.2584783984.to_port:                "22"
      name:                                      "ssh_in"
      owner_id:                                  <computed>
      revoke_rules_on_delete:                    "false"
      vpc_id:                                    "${aws_default_vpc.default_vpc.id}"

  + tls_private_key.terraform-ssh-key
      id:                                        <computed>
      algorithm:                                 "RSA"
      ecdsa_curve:                               "P224"
      private_key_pem:                           <computed>
      public_key_fingerprint_md5:                <computed>
      public_key_openssh:                        <computed>
      public_key_pem:                            <computed>
      rsa_bits:                                  "2048"


Plan: 6 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

]$ 
```

</p>
</details>
  
Finally, if you completed the above steps without errors, you can deploy an EC2 instance with the webserver AMI with
```
terraform apply
```

<details><summary>terraform apply output</summary>
<p>

``` 
]$ terraform apply
data.http.public_ip: Refreshing state...
data.aws_ami.webserver: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

 <= data.aws_subnet_ids.default_subnets
      id:                                        <computed>
      ids.#:                                     <computed>
      tags.%:                                    <computed>
      vpc_id:                                    "${aws_default_vpc.default_vpc.id}"

  + aws_default_vpc.default_vpc
      id:                                        <computed>
      arn:                                       <computed>

... OMITTED ...

  + tls_private_key.terraform-ssh-key
      id:                                        <computed>
      algorithm:                                 "RSA"
      ecdsa_curve:                               "P224"
      private_key_pem:                           <computed>
      public_key_fingerprint_md5:                <computed>
      public_key_openssh:                        <computed>
      public_key_pem:                            <computed>
      rsa_bits:                                  "2048"


Plan: 6 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

tls_private_key.terraform-ssh-key: Creating...
  algorithm:                  "" => "RSA"
  ecdsa_curve:                "" => "P224"
  private_key_pem:            "" => "<computed>"
  public_key_fingerprint_md5: "" => "<computed>"
  public_key_openssh:         "" => "<computed>"
  public_key_pem:             "" => "<computed>"
  rsa_bits:                   "" => "2048"
tls_private_key.terraform-ssh-key: Creation complete after 0s

... OMITTED ...

aws_instance.web: Still creating... (10s elapsed)
aws_instance.web: Still creating... (20s elapsed)
aws_instance.web: Still creating... (30s elapsed)
aws_instance.web: Creation complete after 31s

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

Public IP = X.Y.Z.K
]$ 
```

</p>
</details>
  
Terraform will output the public ip of the EC2 instance. Let's paste it in your browser and... congratulations! you have just deployed a webserver.
Don't forget to destroy the infrastructure you just created if you do not need it anymore
```
terraform destroy
```
## Links

[![Slides IDI 2019](https://drive.google.com/file/d/1NUMbLdIp4tvpWL_wP_AtaJ2bzxzV3Vhr/view?usp=sharing)](https://docs.google.com/presentation/d/1yT9Wa4O3Noi0-nTFar8TkdNbi8HhLk55TsXP8yIhafc/edit?usp=sharing "Slides IDI 2019")  
[![Packer mini example](http://i.vimeocdn.com/video/764685304_200x150.jpg)](https://vimeo.com/321868330 "Video - Packer mini-example.json")  
[![Packer webserver example](http://i.vimeocdn.com/video/764689967_200x150.jpg)](https://vimeo.com/321871067 "Video - Packer webserver.json")  

