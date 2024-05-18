#!/bin/bash
set -eux

# Minimal live iso for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

# install requirements on debian host
#apt update
apt -y install --no-install-recommends grub2 squashfs-tools xorriso debootstrap

mkdir live-bootstrap

# create a minimal debian bootstrap for amd64
debootstrap --arch=amd64 --variant=minbase stable live-bootstrap

# enter bootstrap
chroot live-bootstrap <<"EOT"

# add non-free
echo "deb http://deb.debian.org/debian/ stable main non-free non-free-firmware
deb http://deb.debian.org/debian-security stable-security main non-free non-free-firmware
deb http://deb.debian.org/debian/ stable-updates main non-free non-free-firmware" > /etc/apt/sources.list

apt update
DEBIAN_FRONTEND=noninteractive apt -y upgrade

# install kernel, systemd, basic networking tools and live-boot(so we can boot from this live image)
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends linux-image-amd64 systemd-sysv live-boot ifupdown

# optional installs
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends fdisk grub2 lvm2 cryptsetup debootstrap vim network-manager firmware-iwlwifi ca-certificates git
apt clean

# random mac
echo "[Match]

[Link]
MACAddressPolicy=random" > /etc/systemd/network/00-default.link
EOT
# exit bootstrap

# set root password
chroot live-bootstrap passwd root

# create squashed file system
mkdir -p live-image/live
mksquashfs live-bootstrap live-image/live/filesystem.squashfs -e boot

# copy the kernel and initramfs from inside the bootstrap directory to the image directory
cp live-bootstrap/vmlinuz live-image/vmlinuz
cp live-bootstrap/initrd.img live-image/initrd.img

# create grub config
mkdir -p live-image/boot/grub
echo "set default=\"0\"
set timeout=0
menuentry \"linux\" {
  linux /vmlinuz boot=live
  initrd /initrd.img
}
" > live-image/boot/grub/grub.cfg

# finally create iso
grub-mkrescue -o live-amd64.iso live-image

# write to usb
# dd if=live-amd64.iso of=/dev/sdb bs=1M
