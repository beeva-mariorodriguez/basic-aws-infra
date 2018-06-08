#!/bin/bash

function setup_coreos {
    sudo systemctl enable docker
    echo "REBOOT_STRATEGY=off" | sudo tee -a /etc/coreos/update.conf
}

setup_coreos
docker pull hello-world

