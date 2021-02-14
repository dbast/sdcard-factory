#!/usr/bin/env bash

set -o errtrace -o nounset -o pipefail -o errexit
set -x

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Please specify the device to flash the image to, e.g. /dev/sdd"
    exit 1
fi

dd if=odroid-xu4.img of=/dev/sdd
partprobe
mkdir -p root
mount /dev/sdd1 root
cd root/boot
sh sd_fusing.sh /dev/sdd
cd ../..
umount root
