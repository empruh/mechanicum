variable access_key {}
variable secret_key {}
variable ssh_allowed_cidr {}

provider "aws" {
  region     = "eu-central-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
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

  instances                   = ["${aws_instance.trololol.id}","${aws_instance.ololol.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "Main"
  }

}

#########################################################
### INSTANCES  ##########################################
#########################################################


resource "aws_key_pair" "rand-key" {
  key_name = "rand-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1z4nQ5XH7NUrxYDkLj91GCZD39js2HiVwWcrVA03yKcIiAAP4Bmk77S7KQvfHLSo9Wa7/ZGUfwxK6VSH18g2GgzKgoRuxxed+4Y4EnVtLWvR2+vZz6kLjMpEjXSD/o1siQNvLP69hE0LLM5BkiBvKn2oniyJERkB/53t3u+gvl4cWovV3OuafPwuSjkjvak5ViRMDQzCZ0qh73MI3U5Rd39pG9VdwyF7u06M9Q3tdhJpNRoZozCXnXx24Quti+p/WN5jUGkBUlxg14OPAJKrDkoLuzvWAIJmeStuHuf9XdyKHR5FJD87njrpId8KjBiMWx5rHnq9cBk49kZtUGQQ7bo5PNZtGTXdhwrOhR2ZSqFn7pCzQB8yOCSo6BO/Aq+BNV7REwA5eCCsST+oBkGg4mTQgmrtjxlVmj2bZmKRRF7p4jnNf18WvFNRykLJm/NwyelEjK9TWL9TMji81hN1fT8vVdNndVplQ1LwNKvhT+P1rF7+qV8CHMZwgC+iLXaXKAPtjo3ZpN49xBYBo6pC/GSv0eqZW2CIS49LiTQCLibpjFrNVZCN+SUebzeJ4LrpCc7TJVrFkCKXzYkDyFTT9muIusdfy2wGZ8pLB9JzFYKvLI2gF1xGg5+cRhr1rhYrOyUgE2O0T8xu005hA5vzCo4js/rRWcmkKDBQWq2BmUw=="
}

resource "aws_instance" "trololol" {
  ami           = "ami-1e339e71"
  instance_type = "t2.micro"
  key_name = "rand-key"
  subnet_id = "${aws_subnet.main-a.id}"
  security_groups = [
  "${aws_security_group.rand-vpc-ssh-office.id}"
  ]
  tags {
    Name = "Main"
  }
}

resource "aws_instance" "ololol" {
  ami           = "ami-1e339e71"
  instance_type = "t2.micro"
  key_name = "rand-key"
  subnet_id = "${aws_subnet.main-b.id}"
  security_groups = [
  "${aws_security_group.rand-vpc-ssh-office.id}"
  ]
  tags {
    Name = "Main"
  }
}


