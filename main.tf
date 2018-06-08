# variables
variable "region" {}

variable "keyname" {}
variable "project" {}

# provider
provider "aws" {
  region = "${var.region}"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true

  tags {
    Project = "${var.project}"
  }
}

# network
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.20.2.0/24"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Project = "${var.project}"
  }
}

resource "aws_eip" "nat" {
  depends_on = ["aws_internet_gateway.gw"]
  vpc        = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

## route tables
resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "main"
  }
}

resource "aws_route_table" "custom" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "custom"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.custom.id}"
}

# security groups
resource "aws_security_group" "allow_outbound" {
  name   = "allow_outbound"
  vpc_id = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "${var.project}"
  }
}

# AMIs
data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }
}

# outputs
output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "front_public_ip" {
  value = "${aws_instance.front.public_ip}"
}

output "front_private_ip" {
  value = "${aws_instance.front.private_ip}"
}

output "back_public_ip" {
  value = "${aws_instance.back.public_ip}"
}

output "back_private_ip" {
  value = "${aws_instance.back.private_ip}"
}
