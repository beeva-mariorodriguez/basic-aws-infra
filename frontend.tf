resource "aws_instance" "front" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.public.id}"
  key_name      = "${var.keyname}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.front.id}",
  ]

  tags {
    Project = "${var.project}"
  }
}

resource "aws_security_group" "front" {
  name   = "front"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  tags {
    Project = "${var.project}"
  }
}
