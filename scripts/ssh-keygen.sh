#!/bin/bash
if [[ ! -f secrets/ssh/id_rsa ]]
then
    mkdir -p secrets/ssh/
    chmod -R secrets/
    ssh-keygen -N "" -f secrets/ssh/id_rsa
fi
