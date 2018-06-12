#!/bin/bash

function setup_coreos {
    sudo systemctl enable docker
    echo "REBOOT_STRATEGY=off" | sudo tee -a /etc/coreos/update.conf
}

function setup_bastion {
    mkdir -p "${HOME}/.ssh"
    mv /tmp/id_rsa "${HOME}/.ssh/id_rsa"
    chmod 700 .ssh
    chmod 600 .ssh/id_rsa
}

case $1 in
    "bastion")
        setup_coreos
        setup_bastion
        ;;
    "frontend")
        setup_coreos
        docker pull hello-world
        ;;
    "backend")
        setup_coreos
        docker pull hello-world
        ;;
esac

