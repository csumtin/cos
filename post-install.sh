#!/bin/bash

if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

su - c

cd /home/c

git clone https://github.com/csumtin/cua.git
git clone https://github.com/csumtin/cos.git
git clone https://github.com/csumtin/ccs.git
git clone https://github.com/csumtin/cpl.git

exit

cd /home/c/cua

pip install evdev
cp cua.service /etc/systemd/system/
systemctl enable cua
