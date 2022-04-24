#!/bin/bash
set -eux

# Base install for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

/home/c/proj/cap/cua/init.sh &
/home/c/proj/cap/gedit/init.sh &
/home/c/proj/cap/firefox/init.sh &
/home/c/proj/cap/template/init.sh &

wait

