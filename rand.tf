variable access_key {}
variable secret_key {}
variable ssh_allowed_cidr {}
variable ssh_public_key {}

provider "aws" {
  region     = "eu-central-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

provider "openstack" {
  auth_url = "https://auth.cloud.ovh.net/v3"
  domain_name = "default"
  alias = "ovh"
}

#########################################################
### NETWORK / SECGROUPS  ################################
#########################################################

resource "aws_vpc" "rand-main" {
  cidr_block = "172.16.0.0/16"
  tags {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "rand-main-gw" {
  vpc_id = "${aws_vpc.rand-main.id}"

  tags {
    Name = "Main"
  }
}


resource "aws_subnet" "main-a" {
  vpc_id     = "${aws_vpc.rand-main.id}"
  cidr_block = "172.16.1.0/24"
  availability_zone = "eu-central-1a"
        map_public_ip_on_launch = "True"
  tags {
    Name = "Main"
  }
}

resource "aws_subnet" "main-b" {
  vpc_id     = "${aws_vpc.rand-main.id}"
  cidr_block = "172.16.2.0/24"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = "True"
  tags {
    Name = "Main"
  }
}

resource "aws_subnet" "main-c" {
  vpc_id     = "${aws_vpc.rand-main.id}"
  cidr_block = "172.16.3.0/24"
  availability_zone = "eu-central-1c"
  map_public_ip_on_launch = "True"
  tags {
    Name = "Main"
  }
}


resource "aws_security_group" "rand-vpc-ssh-office" {
  name        = "rand-vpc-ssh-office"
  description = "Allow ssh from office"
  vpc_id      = "${aws_vpc.rand-main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${var.ssh_allowed_cidr}" ]
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

#########################################################
### ELB  ################################################
#########################################################

resource "aws_elb" "rand-elb" {
  name               = "rand-elb"
#availability_zones = ["eu-central-1a", "eu-central-1b"]
  subnets = ["${aws_subnet.main-a.id}","${aws_subnet.main-b.id}" ]

  access_logs {
    bucket        = "rand-elb-bucket"
    bucket_prefix = "rand"
    interval      = 60
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.frontend-1a.id}","${aws_instance.frontend-1b.id}","{aws_instance.frontend-1c.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "Main"
  }

}
resource "aws_s3_bucket" "rand-elb-bucket" {
  bucket = "rand-elb-bucket"
  acl    = "private"

  tags {
    Name        = "Main"
  }
}


#########################################################
### INSTANCES  ##########################################
#########################################################


resource "aws_key_pair" "rand-key" {
  key_name = "rand-key"
  public_key = "${var.ssh_public_key}"
}

resource "aws_instance" "frontend-1a" {
  ami           = "ami-1e339e71"
  instance_type = "t2.large"
  key_name = "rand-key"
  subnet_id = "${aws_subnet.main-a.id}"
  security_groups = [
  "${aws_security_group.rand-vpc-ssh-office.id}"
  ]
  tags {
    Name = "Main"
  }
}

resource "aws_instance" "frontend-1b" {
  ami           = "ami-1e339e71"
  instance_type = "t2.large"
  key_name = "rand-key"
  subnet_id = "${aws_subnet.main-b.id}"
  security_groups = [
  "${aws_security_group.rand-vpc-ssh-office.id}"
  ]
  tags {
    Name = "Main"
  }
}

resource "aws_instance" "frontend-1c" {
  ami           = "ami-1e339e71"
  instance_type = "t2.large"
  key_name = "rand-key"
  subnet_id = "${aws_subnet.main-c.id}"
  security_groups = [
  "${aws_security_group.rand-vpc-ssh-office.id}"
  ]
  tags {
    Name = "Main"
  }
}

