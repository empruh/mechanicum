provider "aws" {
  region     = "eu-central-1"
}

resource "aws_instance" "trololol" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
resource "aws_instance" "ololol" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
