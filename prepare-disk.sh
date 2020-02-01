#!/bin/bash
set -eux

# Base install for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

# Will install on disk passed in as first argument
DISK_TO_USE=$1
if [[ -f ${DISK_TO_USE} ]]; then
    echo "Error: $1 is not a valid disk"
    exit 1
fi

wipefs -f -a ${DISK_TO_USE}

echo "o
w" | fdisk ${DISK_TO_USE}

echo "n
p
1


a
w
" | fdisk ${DISK_TO_USE}

yes | pvcreate ${DISK_TO_USE}1
yes | vgcreate vg ${DISK_TO_USE}1
