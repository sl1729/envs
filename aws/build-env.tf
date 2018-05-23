# Configure the Terraform backend
terraform {
  backend "s3" {
    bucket = "sl1729"
    region = "ap-southeast-1"
    key    = "terraform.tfstate"
  }
}

# Configure the region in which it works
provider "aws" {
    region              = "ap-southeast-1"
}

resource "aws_lb" "jboss-lb" {
    name                = "jboss-lb"
    internal            = false
    load_balancer_type  = "application"
    subnets             = ["subnet-18f5cb5e","subnet-ad9596c9","subnet-480a3e3e"]
    enable_deletion_protection = false
}

data "aws_ami" "jboss_ami" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["jboss-*"]
  }

  owners     = ["702039097694"]
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

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow access everywhere"
    }

    tags {
        Name = "allow_jboss"
    }
}

resource "aws_instance" "jboss-node" {
    ami               = "${data.aws_ami.jboss_ami.id}"
    instance_type     = "t2.large"
    key_name          = "ItsFun2WorkNow"
    security_groups   = [ "allow_jboss" ]
    user_data         = "<bash>sudo systemctl restart jboss-as-standalone.service</bash>"
    count             = 3
}
