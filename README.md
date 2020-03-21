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
* prepare disk with `fdisk /dev/sda` and select option o,w then n,p,1,a,w
* connect to internet `nmcli device wifi connect AP_NAME password AP_PASSWORD`
* clone this repo `git clone https://github.com/csumtin/cos.git`
* `./prepare-disk.sh /dev/sda`, use correct disk name!
* Assuming that the above worked, you will have a volume group named vg
* `./install-os.sh /dev/sda`, use correct disk name!
