#!/bin/bash

# Base install for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

# sound
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends pulseaudio

# bluetooth
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends gnome-bluetooth pulseaudio-module-bluetooth

# for cua
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends python3-pip python3-setuptools linux-headers-$(uname -r) python3-dev gcc

# for cas
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends steghide gnupg pwgen xclip

cd /home/c
git clone https://github.com/csumtin/cua.git
git clone https://github.com/csumtin/ccs.git
git clone https://github.com/csumtin/cpl.git
chown -R c:c cua
chown -R c:c ccs
chown -R c:c cpl

cd /home/c/cua
pip install evdev
cp cua0.service /etc/systemd/system/
systemctl enable cua0
