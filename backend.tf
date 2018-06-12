resource "aws_instance" "back" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.private.id}"
  key_name      = "${var.project}-bastion"
  depends_on    = ["aws_instance.bastion"]

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.back.id}",
  ]

  tags {
    Name    = "back"
    Project = "${var.project}"
  }

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh backend",
    ]
  }

  connection {
    type         = "ssh"
    user         = "core"
    bastion_host = "${aws_instance.bastion.public_ip}"
    bastion_user = "core"
    agent        = false
    host         = "${self.private_ip}"

    # both keys must be the same:
    #   https://github.com/hashicorp/terraform/issues/6263

    private_key         = "${chomp(file("secrets/ssh/id_rsa"))}"
    bastion_private_key = "${chomp(file("secrets/ssh/id_rsa"))}"
  }
}

resource "aws_security_group" "back" {
  name   = "back"
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
