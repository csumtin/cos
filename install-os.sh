#!/bin/bash
set -eux

# Base install for an amd64 debian system
if [[ $EUID -ne 0  ]]; then
  echo "This script must be run as root"
  exit 1
fi

DISK_TO_USE=$1
PARTITION_TO_USE=$2

yes | pvcreate ${PARTITION_TO_USE}
yes | vgcreate vg ${PARTITION_TO_USE}

lvcreate --size 1G --name boot vg
lvcreate --size 50G --name root vg
lvcreate -l 100%FREE --name backup vg

echo "Pick luks password for root"
cryptsetup -q luksFormat --iter-time 2000 --cipher aes-xts-plain64 --key-size 512 --hash sha512 /dev/mapper/vg-root
cryptsetup luksOpen /dev/mapper/vg-root decrypt-root

echo "Pick luks password for backup"
cryptsetup -q luksFormat --iter-time 2000 --cipher aes-xts-plain64 --key-size 512 --hash sha512 /dev/mapper/vg-backup
cryptsetup luksOpen /dev/mapper/vg-backup decrypt-backup

yes | mkfs -t ext4 /dev/mapper/vg-boot
yes | mkfs -t ext4 /dev/mapper/decrypt-root
yes | mkfs -t ext4 /dev/mapper/decrypt-backup

mkdir /mnt/base
debootstrap --arch=amd64 --variant=minbase stable /mnt/base

mount --bind /dev /mnt/base/dev
mount --bind /proc /mnt/base/proc
mount --bind /sys /mnt/base/sys

echo "Pick root password"
chroot /mnt/base passwd root

echo "Add user c"
chroot /mnt/base apt -y install --no-install-recommends adduser
chroot /mnt/base adduser c

chroot /mnt/base /usr/bin/env DISK_TO_USE=${DISK_TO_USE} /bin/bash <<"EOT"
echo "/dev/mapper/vg-boot  /boot  ext4  defaults,noatime  0 2
/dev/mapper/decrypt-root  /  ext4  defaults,noatime,errors=remount-ro  0 1" > /etc/fstab

# add non-free
echo "deb http://deb.debian.org/debian/ stable main non-free non-free-firmware
deb http://deb.debian.org/debian-security stable-security main non-free non-free-firmware
deb http://deb.debian.org/debian/ stable-updates main non-free non-free-firmware" > /etc/apt/sources.list

apt update
DEBIAN_FRONTEND=noninteractive apt -y upgrade

# install kernel, systemd, grub, lvm and luks
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends linux-image-amd64 busybox systemd-sysv grub-pc os-prober lvm2 cryptsetup cryptsetup-initramfs

echo 'CRYPTSETUP=y' > /etc/cryptsetup-initramfs/conf-hook

echo '#!/bin/sh
PREREQ="lvm"
case "$1" in
  prereqs)
    echo "$PREREQ"
    exit 0
    ;;
esac

umask 077
KEY=/run/key
trap '\''rm "$KEY"'\'' EXIT

while true; do
  /lib/cryptsetup/askpass "Password: " > "$KEY"

  if /sbin/cryptsetup open --key-file="$KEY" /dev/mapper/vg-root decrypt-root 2>/dev/null || /sbin/cryptsetup open --key-file="$KEY" /dev/mapper/vg-backup decrypt-root 2>/dev/null
  then
    exit 0
  fi
done
' > /etc/initramfs-tools/scripts/local-top/boty
chmod 755 /etc/initramfs-tools/scripts/local-top/boty

# command line text editing
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends nano

# networking and wifi
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends network-manager firmware-iwlwifi wpasupplicant ca-certificates nftables

# bluetooth
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends bluez

echo "127.0.0.1 localhost
::1 localhost" > /etc/hosts

echo '#!/usr/sbin/nft -f
flush ruleset

table inet filter {
  chain input {
    # drop by default
    type filter hook input priority 0; policy drop;
    # accept localhost
    iif lo accept
    # drop connections to localhost not coming from localhost
    iif != lo ip daddr 127.0.0.1/8 drop
    # drop connections to localhost not coming from localhost
    iif != lo ip6 daddr ::1/128 drop
    # only accept traffic originating from us
    ct state {established, related} accept
  }
  chain forward {
    # drop by default
    type filter hook forward priority 0; policy drop;
  }
  chain output {
    # drop by default
    type filter hook output priority 0; policy drop;
    # accept localhost
    oif lo accept
    # allow outbound http, https and ssh
    tcp dport {80, 443, 22} ct state new,established,related accept
    # allow outbound dns
    udp dport 53 ct state new,established,related accept
  }
}' > /etc/nftables.conf

systemctl enable nftables

# minimal gnome desktop environment
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends gnome-session gdm3 gnome-control-center libgl1-mesa-dri x11-xserver-utils gnome-terminal

apt clean

# grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/' /etc/default/grub
echo 'GRUB_CMDLINE_LINUX="root=/dev/mapper/decrypt-root"' >> /etc/default/grub

EOT

umount /mnt/base/dev
umount /mnt/base/proc
umount /mnt/base/sys

mkdir /mnt/root
mount /dev/mapper/decrypt-root /mnt/root
cp -a /mnt/base/. /mnt/root

mkdir /mnt/backup
mount /dev/mapper/decrypt-backup /mnt/backup
mkdir /mnt/backup/boot
mount /dev/mapper/vg-boot /mnt/backup/boot
cp -a /mnt/base/. /mnt/backup

mount --bind /dev /mnt/backup/dev
mount --bind /proc /mnt/backup/proc
mount --bind /sys /mnt/backup/sys

chroot /mnt/backup /usr/bin/env DISK_TO_USE=${DISK_TO_USE} /bin/bash <<"EOT"
# run software in containers using deboostrap and systemd containers
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends debootstrap systemd-container sudo

# give c user permission to run systemd-nspawn
echo "c	ALL=NOPASSWD:/usr/bin/systemd-nspawn" >> /etc/sudoers

# random mac
echo "[Match]

[Link]
MACAddressPolicy=random" > /etc/systemd/network/00-default.link

# git
DEBIAN_FRONTEND=noninteractive apt -y install --no-install-recommends git

apt clean

update-initramfs -u -k all
update-grub
grub-install --target=i386-pc ${DISK_TO_USE}

su - c

mkdir proj download

git clone https://github.com/csumtin/cap.git
EOT

echo "Base OS installed, you should reboot"
