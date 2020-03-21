#!/bin/bash
set -eux

# Base install for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

DISK_TO_USE=$1

yes | pvcreate ${DISK_TO_USE}1
yes | vgcreate vg ${DISK_TO_USE}1

if ! vgdisplay | grep -q 'vg' ; then
    echo "Error: expecting volume group vg"
    exit 1
fi

lvcreate --size 1G --name boot vg
lvcreate -l 100%FREE --name root vg

echo "Pick luks password"
cryptsetup -q luksFormat --iter-time 2000 --cipher aes-xts-plain64 --key-size 512 --hash sha512 /dev/mapper/vg-root
cryptsetup luksOpen /dev/mapper/vg-root decrypt-root

yes | mkfs.ext4 /dev/mapper/vg-boot
yes | mkfs.ext4 /dev/mapper/decrypt-root

mount /dev/mapper/decrypt-root /mnt
mkdir /mnt/boot
mount /dev/mapper/vg-boot /mnt/boot

mkdir bootstrap
debootstrap --arch=amd64 --variant=minbase stable bootstrap
cp -Rp bootstrap/* /mnt

mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys

mkdir /mnt/run/udev
mount --bind /run/udev /mnt/run/udev

echo "Pick root password"
chroot /mnt passwd root

echo "Add user c"
chroot /mnt adduser c

chroot /mnt /usr/bin/env DISK_TO_USE=${DISK_TO_USE} /bin/bash <<"EOT"
echo "decrypt-root /dev/mapper/vg-root  none  luks" > /etc/crypttab

echo "/dev/mapper/vg-boot  /boot  ext4  defaults  0 2
/dev/mapper/decrypt-root  /  ext4  errors=remount-ro  0 1" > /etc/fstab

# add non-free
echo "deb http://deb.debian.org/debian/ stable main non-free
deb http://deb.debian.org/debian-security stable/updates main non-free
deb http://deb.debian.org/debian/ stable-updates main non-free" > /etc/apt/sources.list

apt update
DEBIAN_FRONTEND=noninteractive apt -y upgrade

# install kernel, systemd, grub, lvm and luks
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends linux-image-amd64 busybox systemd-sysv grub2 os-prober lvm2 cryptsetup

# command line text editing
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends less nano xxd

# run software in containers using deboostrap and systemd containers
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends debootstrap systemd-container sudo

# give c user permission to run systemd-nspawn
echo "c	ALL=NOPASSWD:/usr/bin/systemd-nspawn" >> /etc/sudoers

# networking and wifi
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends firmware-iwlwifi ifupdown network-manager ca-certificates nftables

# random mac
echo "[MATCH]

[LINK]
MACAddressPolicy=random" > /etc/systemd/network/00-default.link

echo "127.0.0.1 localhost
::1 localhost" > /etc/hosts

# minimal gnome desktop environment
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends gnome-session gdm3 gnome-control-center libgl1-mesa-dri x11-xserver-utils gnome-terminal gedit

# sound
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends pulseaudio

DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends git bash-completion

# for cua
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends python-pip python-setuptools linux-headers-$(uname -r) python-dev gcc

# for cas
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends steghide gnupg pwgen xclip

apt clean

# grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/' /etc/default/grub

update-grub
grub-install ${DISK_TO_USE}

cd /home/c
git clone https://github.com/csumtin/cua.git
git clone https://github.com/csumtin/cos.git
git clone https://github.com/csumtin/ccs.git
git clone https://github.com/csumtin/cpl.git
chown -R c:c cua
chown -R c:c cos
chown -R c:c ccs
chown -R c:c cpl

cd /home/c/cua

pip install evdev
cp cua.service /etc/systemd/system/
systemctl enable cua

EOT

echo "Base OS installed, you should reboot"
