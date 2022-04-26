#!/bin/bash
set -eux

if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

/home/c/proj/cap/cua/init.sh
/home/c/proj/cap/gedit/init.sh
/home/c/proj/cap/firefox/init.sh
/home/c/proj/cap/google-chrome/init.sh
/home/c/proj/cap/template/init.sh

