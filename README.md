# OS setup

## Minimal Bootable Live Image
* create from debian host by running `./live-iso.sh`
* copy live-amd64.iso to usb(sdb) `dd if=live-amd64.iso of=/dev/sdb bs=1M`

## OS Install
* machine needs a disk of at least 60G and UEFI turned OFF
* **WARNING** will completely wipe disk!!
* **BACKUP** your data!
* boot into the minimal live image
* `wipefs -f -a /dev/sda` to make sure the disk is clean and then reboot
* connect to internet `nmcli device wifi connect AP_NAME password AP_PASSWORD`
* clone this repo `git clone https://github.com/csumtin/cos.git`
* prepare disk with `fdisk /dev/sda` and select option o,w then n,p,1,a,w
* `./install-os.sh /dev/sda`, use correct disk name!

## Post Install
* reboot and run `post-install-as-c.sh` and `post-install-as-root.sh`
* for each keyboard `cp cua.service /etc/systemd/system/` and `systemctl enable cua`
* `git clone cas`
