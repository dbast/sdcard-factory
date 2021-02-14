#!/usr/bin/env bash

set -o errtrace -o pipefail -o errexit
set -x

hostname="nas${RANDOM}"
# shellcheck disable=SC2153
username="${USERNAME}"

# Recomended in https://wiki.archlinux.org/index.php/Chroot#Using_chroot
# Doesn't seem to do much
# shellcheck disable=SC1091
source /etc/profile

# Debug info
env | sort

# First boot install step: https://archlinuxarm.org/platforms/armv7/samsung/odroid-hc2
pacman-key --init
pacman-key --populate archlinuxarm

# Enable network connection
if [[ -L /etc/resolv.conf ]]; then
  mv /etc/resolv.conf /etc/resolv.conf.bk;
fi
echo 'nameserver 8.8.8.8' > /etc/resolv.conf;
pacman -Sy --noconfirm --needed

# Set up localization https://wiki.archlinux.org/index.php/Installation_guide#Localization
#sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
#locale-gen
#echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# set up resize firstrun script
mv /tmp/resizerootfs.service /etc/systemd/system
chmod +x /tmp/resizerootfs
mv /tmp/resizerootfs /usr/sbin/
systemctl enable resizerootfs.service

# Set Hostname
echo "${hostname}" > /etc/hostname

# Install tools and yay dependencies
pacman -S git base-devel binutils htop parted sudo vim --noconfirm --needed

# Set up no-password sudo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

# disable password auth
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# enable color on pacman
sed -i 's/#Color/Color/g' /etc/pacman.conf

# create user
useradd -m "${username}"
usermod -aG wheel "${username}"
# delete default user alarm:alarm
# Comment out for debugability.
userdel -r alarm
# disable root login root:root
# https://wiki.archlinux.org/index.php/Sudo#Disable_root_login
passwd -l root

# Setup user ssh keys
mkdir /home/"${username}"/.ssh
touch "/home/${username}/.ssh/authorized_keys"
curl "https://github.com/${username}.keys" > "/home/${username}/.ssh/authorized_keys"
chown -R "${username}:${username}" "/home/${username}/.ssh"
chmod go-w "/home/${username}"
chmod 700 "/home/${username}/.ssh"
chmod 600 "/home/${username}/.ssh/authorized_keys"
mv /tmp/first-boot.sh "/home/${username}/"
chown "${username}:${username}" "/home/${username}/first-boot.sh"

# restore original resolve.conf
if [[ -L /etc/resolv.conf.bk ]]; then
  mv /etc/resolv.conf.bk /etc/resolv.conf;
fi
