resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.public.id}"
  key_name      = "${var.keyname}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.bastion.id}",
  ]

  tags {
    Project = "${var.project}"
  }
}

resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "${var.project}"
  }
}
