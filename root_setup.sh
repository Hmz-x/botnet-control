#!/bin/bash

user="hkm"

root_check() 
{
    if [[ $UID -ne 0 ]]; then
        echo "Run as root. Exiting." >&2
        exit 1
    fi
}

root_check

dnf update && dnf upgrade
dnf install -y vim tmux git tor

useradd -m "$user"
usermod "$user" -aG network,wheel,disk,input,storage
