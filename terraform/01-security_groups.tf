data "http" "public_ip" {
   url = "https://ipecho.net/plain"
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_security_group" "ssh_in" {
  name        = "ssh_in"
  description = "Allow SSH Traffic"
  vpc_id      = "${aws_default_vpc.default_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.public_ip.body}/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http_in" {
  name        = "http_in"
  description = "Allow HTTP Traffic"
  vpc_id      = "${aws_default_vpc.default_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${data.http.public_ip.body}/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
