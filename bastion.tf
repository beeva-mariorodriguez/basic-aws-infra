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
    Name    = "bastion"
    Project = "${var.project}"
  }

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
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
