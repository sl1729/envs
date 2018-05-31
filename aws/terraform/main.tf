resource "aws_vpc" "rgb" {
  cidr_block = "172.36.0.0/16"

  tags {
    Name = "My VPC"
  }
}

resource "aws_internet_gateway" "rgb-ig" {
  vpc_id = "${aws_vpc.rgb.id}"

  tags {
    Name = "Default internet gateway"
  }
}

resource "aws_subnet" "zone-a" {
  vpc_id            = "${aws_vpc.rgb.id}"
  cidr_block        = "172.36.10.0/24"
  availability_zone = "ap-southeast-1a"

  tags {
    Name = "Zone A"
  }
}

resource "aws_subnet" "zone-b" {
  vpc_id            = "${aws_vpc.rgb.id}"
  cidr_block        = "172.36.20.0/24"
  availability_zone = "ap-southeast-1b"

  tags {
    Name = "Zone B"
  }
}

resource "aws_subnet" "zone-c" {
  vpc_id            = "${aws_vpc.rgb.id}"
  cidr_block        = "172.36.30.0/24"
  availability_zone = "ap-southeast-1c"

  tags {
    Name = "Zone C"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.rgb.default_route_table_id}"

  tags {
    Name = "Default routing table"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_default_route_table.default.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.rgb-ig.id}"
}

resource "aws_route_table_association" "zone-a-assoc" {
  subnet_id      = "${aws_subnet.zone-a.id}"
  route_table_id = "${aws_default_route_table.default.id}"
}

resource "aws_route_table_association" "zone-b-assoc" {
  subnet_id      = "${aws_subnet.zone-b.id}"
  route_table_id = "${aws_default_route_table.default.id}"
}

resource "aws_route_table_association" "zone-c-assoc" {
  subnet_id      = "${aws_subnet.zone-c.id}"
  route_table_id = "${aws_default_route_table.default.id}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.rgb.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "default"
  }
}

resource "aws_elb" "jboss-elb" {
  name                        = "jboss-elb"
  subnets                     = ["${aws_subnet.zone-a.id}", "${aws_subnet.zone-b.id}", "${aws_subnet.zone-c.id}"]
  instances                   = ["${aws_instance.jboss-instance-zone-a.id}", "${aws_instance.jboss-instance-zone-b.id}", "${aws_instance.jboss-instance-zone-c.id}"]
  cross_zone_load_balancing   = "true"
  idle_timeout                = "400"
  connection_draining         = "true"
  connection_draining_timeout = "400"
  security_groups             = ["${aws_default_security_group.default.id}"]

  listener {
    instance_port     = "9990"
    instance_protocol = "http"
    lb_port           = "80"
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 30
    target              = "HTTP:9990/console/index.html"
    interval            = 40
  }
}

resource "aws_lb_cookie_stickiness_policy" "jboss-cookie-policy" {
  name                     = "jboss-cookie-policy"
  load_balancer            = "${aws_elb.jboss-elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

data "aws_ami" "jboss-ami" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["jboss-eap-6.4.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${var.owner_id}"]
}

resource "aws_instance" "jboss-instance-zone-a" {
  ami                         = "${data.aws_ami.jboss-ami.id}"
  instance_type               = "${var.instance-type}"
  subnet_id                   = "${aws_subnet.zone-a.id}"
  associate_public_ip_address = "true"
  key_name                    = "${var.access-key}"
}

resource "aws_instance" "jboss-instance-zone-b" {
  ami                         = "${data.aws_ami.jboss-ami.id}"
  instance_type               = "${var.instance-type}"
  subnet_id                   = "${aws_subnet.zone-b.id}"
  associate_public_ip_address = "true"
  key_name                    = "${var.access-key}"
}

resource "aws_instance" "jboss-instance-zone-c" {
  ami                         = "${data.aws_ami.jboss-ami.id}"
  instance_type               = "${var.instance-type}"
  subnet_id                   = "${aws_subnet.zone-c.id}"
  associate_public_ip_address = "true"
  key_name                    = "${var.access-key}"
}
