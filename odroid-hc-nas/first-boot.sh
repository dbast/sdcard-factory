#!/usr/bin/env bash

set -o errtrace -o pipefail -o errexit

# Install yay
curl -kL https://github.com/Jguer/yay/releases/download/v10.1.2/yay_10.1.2_armv7h.tar.gz -o yay.tar.gz
tar -xf yay.tar.gz && ./yay_10.1.2_armv7h/yay -S yay-bin && rm -rf yay*

# Update all
yay -Syu

# More tools
yay -S fzf fd exa

# Mount data disk
sudo mkdir -p /data
echo "LABEL=nas-data     /data    ext4   defaults 0 0" | sudo tee -a /etc/fstab
sudo mount /data

# Install rslsync
yay -S rslsync
# org: /etc/rslsync.conf "storage_path" : "/var/lib/rslsync",
sudo cp /etc/rslsync.conf /etc/rslsync.conf.org
sudo cp /data/backup/rslsync.conf /etc/rslsync.conf
sudo systemctl enable rslsync
sudo systemctl start rslsync

# clean
yay -Scc