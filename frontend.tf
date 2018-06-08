resource "aws_instance" "front" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.public.id}"
  key_name      = "${var.project}-bastion"
  depends_on    = ["aws_instance.bastion"]

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.front.id}",
  ]

  tags {
    Name    = "front"
    Project = "${var.project}"
  }

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh frontend",
    ]
  }

  connection {
    type         = "ssh"
    user         = "core"
    bastion_host = "${aws_instance.bastion.public_ip}"
    bastion_user = "core"
    timeout      = "2m"
  }
}

resource "aws_security_group" "front" {
  name   = "front"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    # security_groups = ["${aws_security_group.bastion.id}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "${var.project}"
  }
}
