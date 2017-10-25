provider "aws" {
  region     = "eu-central-1"
}

resource "aws_vpc" "rand-main" {
  cidr_block = "172.16.0.0/16"
  tags {
    Name = "rand-main"
  }
}

resource "aws_security_group" "rand-vpc-ssh-office" {
  name        = "rand-vpc-ssh-office"
  description = "Allow ssh from office"
  vpc_id      = "${aws_vpc.rand-main.id}"

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["81.93.113.12/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "Main"
    }
}

resource "aws_subnet" "main-a" {
  vpc_id     = "${aws_vpc.rand-main.id}"
  cidr_block = "172.16.1.0/24"
  availability_zone = "eu-central-1a" 
  tags {
    Name = "Main"
  }
}

resource "aws_subnet" "main-b" {
  vpc_id     = "${aws_vpc.rand-main.id}"
  cidr_block = "172.16.2.0/24"
  availability_zone = "eu-central-1b"
  tags {
    Name = "Main"
  }
}

resource "aws_instance" "trololol" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  security_groups = [
  "rand-vpc-ssh-office"
  ]
  tags {
    Name = "rand-main"
  }
}

resource "aws_instance" "ololol" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  security_groups = [
  "rand-vpc-ssh-office"
  ]
  tags {
    Name = "rand-main"
  }
}


