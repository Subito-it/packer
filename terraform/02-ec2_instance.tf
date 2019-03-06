data "aws_ami" "webserver" {
  most_recent      = true
  owners = ["self"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["*webserver*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}


data "aws_subnet_ids" "default_subnets" {
  vpc_id = "${aws_default_vpc.default_vpc.id}"
}

resource "tls_private_key" "terraform-ssh-key" {
  algorithm   = "RSA"
}

resource "aws_key_pair" "terraform-ssh-key" {
  key_name = "terraform-ssh-key"
  public_key = "${tls_private_key.terraform-ssh-key.public_key_openssh}"
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.webserver.id}"
  instance_type = "t2.micro"
  associate_public_ip_address  = "true"
  subnet_id = "${data.aws_subnet_ids.default_subnets.ids[0]}"
  vpc_security_group_ids = ["${aws_security_group.ssh_in.id}","${aws_security_group.http_in.id}"]
  instance_initiated_shutdown_behavior = "terminate"
  key_name = "${aws_key_pair.terraform-ssh-key.key_name}"
  root_block_device {
      volume_type = "standard"
      volume_size = 3
      delete_on_termination = true
    }
  tags = {
    Name = "terraform packer deploy"
  }
}

output "Public IP" {
  value = "${aws_instance.web.public_ip}"
}
