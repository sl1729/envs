# Configure the Terraform backend
terraform {
  backend "s3" {
    bucket = "sl1729"
    region = "ap-southeast-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region     = "ap-southeast-1"
}

resource "aws_instance" "node1" {
  ami               = "ami-cdf8cab1"
  instance_type     = "t2.large"
  key_name          = "ItsFun2WorkNow"
  security_groups   = [ "allow_jboss" ]
  user_data         = "<bash>sudo systemctl restart jboss-as-standalone.service</bash>"
}

resource "aws_security_group" "allow_jboss" {
  name        = "allow_jboss"
  description = "Allow all inbound traffic around jboss"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9990
    to_port     = 9990
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

