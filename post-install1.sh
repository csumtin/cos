#!/bin/bash

# Base install for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

# sound
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends pulseaudio

# bluetooth
# DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends gnome-bluetooth pulseaudio-module-bluetooth

# for cas
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends steghide gnupg pwgen xclip
